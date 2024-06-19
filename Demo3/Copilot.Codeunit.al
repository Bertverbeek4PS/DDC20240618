codeunit 70104 "Copilot demo3"
{
    trigger OnRun()
    begin

    end;

    procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        LearnMoreUrlTxt: Label 'https://www.bertverbeek.nl', locked = true;
    begin
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Ingest csv file") then
            CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Ingest csv file", Enum::"Copilot Availability"::Preview, LearnMoreUrlTxt);
    end;

    procedure Generate(var InStr: InStream): text
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        Result: Text;
        Prompt: text;
    begin
        SetAuthoration(AzureOpenAI);

        AOAIChatCompletionParams.SetTemperature(0);

        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Ingest csv file");
        AOAIChatMessages.AddSystemMessage(GetSystemPrompt());

        AOAIChatMessages.AddUserMessage(GetUserPrompt(InStr));

        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);

        if AOAIOperationResponse.IsSuccess() then
            Result := AOAIChatMessages.GetLastMessage()
        else
            Error(AOAIOperationResponse.GetError());

        exit(Result);
    end;

    local procedure SetAuthoration(var OpenAzureAI: Codeunit "Azure OpenAI")
    var
        Endpoint: Text;
        Deployment: Text;
        [NonDebuggable]
        APIKey: Text;
    begin
        IsolatedStorage.Get('Copilot-Endpoint', Endpoint);
        IsolatedStorage.Get('Copilot-Deployment', Deployment);
        IsolatedStorage.Get('Copilot-ApiKey', ApiKey);

        OpenAzureAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", Endpoint, Deployment, APIKey);
    end;

    local procedure GetSystemPrompt(): Text
    var
        SystemPrompt: TextBuilder;
    begin
        //Put this not in your app but in a keyvault
        SystemPrompt.AppendLine('You are an AI assistant that map fields from an import file to a table.');
        SystemPrompt.AppendLine('');
        SystemPrompt.AppendLine('IMPORTANT:');
        SystemPrompt.AppendLine('Your answer must be in an XML format.');
        SystemPrompt.AppendLine('You only map the fields from the import file and the table and nothing else.');
        SystemPrompt.AppendLine('Also number the mapping from 1 to 100. And it must be in a node.');
        SystemPrompt.AppendLine('You can only have one root element.');
        SystemPrompt.AppendLine('');
        SystemPrompt.AppendLine('SAMPLE:');
        SystemPrompt.AppendLine('<root>');
        SystemPrompt.AppendLine('  <mapping>');
        SystemPrompt.AppendLine('    <number>1</number>');
        SystemPrompt.AppendLine('    <importField>CustomerNo</importField>');
        SystemPrompt.AppendLine('    <tableField > Customer Number</tableField>');
        SystemPrompt.AppendLine('  </mapping>');
        SystemPrompt.AppendLine('  <mapping>');
        SystemPrompt.AppendLine('    <number>2</number>');
        SystemPrompt.AppendLine('    <importField>CustomerName</importField>');
        SystemPrompt.AppendLine('    <tableField>Name</tableField>');
        SystemPrompt.AppendLine('  </mapping>');
        SystemPrompt.AppendLine('</root>');
        exit(SystemPrompt.ToText());
    end;

    local procedure GetUserPrompt(InStr: InStream): Text
    var
        Field: record Field;
        UserPrompt: TextBuilder;
        ImportText: Text;
        Firstline: Text;
    begin
        InStr.ReadText(ImportText, 100);
        while not InStr.EOS do begin
            Firstline := ImportText;

            if Firstline <> '' then
                break;
        end;
        UserPrompt.AppendLine('The first line of the import file is:');
        UserPrompt.AppendLine(Firstline);
        UserPrompt.AppendLine('This is with semicolon seperated fields.');
        UserPrompt.AppendLine('');
        UserPrompt.AppendLine('The fields in the table are:');
        Field.Reset;
        Field.SetRange(TableNo, Database::"Customer Import");
        if Field.FindSet() then begin
            repeat
                UserPrompt.AppendLine(Field.FieldName);
            until Field.Next() = 0;
        end;
        exit(UserPrompt.ToText());
    end;

    procedure ProcessFile(Result: Text; InStr: InStream)
    var
        FldRef: FieldRef;
        CSVBuffer: Record "CSV Buffer" temporary;
        lCustomerImport: RecordRef;
        CustomerImport: Record "Customer Import";
        MappingTable: Record "Mapping table";
        MyDate: Date;
    begin
        CSVBuffer.LoadDataFromStream(InStr, ';');

        CustomerImport.DeleteAll(); //just for the demo
        lCustomerImport.Open(Database::"Customer Import");
        if CSVBuffer.FindSet() then
            repeat
                if (CSVBuffer."Field No." = 1) then begin
                    lCustomerImport.Init();
                    lCustomerImport.Field(1).Value := CSVBuffer."Line No." + 1;
                    lCustomerImport.Insert(true);
                end;

                if MappingTable.FindSet() then
                    repeat
                        if MappingTable.tableField = (CSVBuffer."Field No." + 1) then begin
                            FldRef := lCustomerImport.Field(MappingTable.tableField);
                            if (CSVBuffer."Field No." = 4) or (CSVBuffer."Field No." = 5) then begin
                                Evaluate(MyDate, CSVBuffer.Value);
                                FldRef.Value := MyDate;
                            end else
                                FldRef.Value := CSVBuffer.Value;
                            lCustomerImport.Modify(true);
                        end;
                    until MappingTable.Next() = 0;

            until CSVBuffer.Next() = 0;

        lCustomerImport.Close();
    end;
}