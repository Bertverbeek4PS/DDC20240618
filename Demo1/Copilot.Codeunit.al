codeunit 70103 "Copilot demo1"
{
    trigger OnRun()
    begin

    end;

    procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        LearnMoreUrlTxt: Label 'https://www.bertverbeek.nl', locked = true;
    begin
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Predict capital") then
            CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Predict capital", Enum::"Copilot Availability"::Preview, LearnMoreUrlTxt);
    end;

    procedure Generate(var userinput: Text): Text
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        Result: Text;
        Prompt: text;
    begin
        SetAuthoration(AzureOpenAI);

        AOAIChatCompletionParams.SetMaxTokens(5000);
        AOAIChatCompletionParams.SetTemperature(0);

        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Predict capital");
        AOAIChatMessages.AddSystemMessage(GetSystemPrompt());

        Prompt := userinput;
        AOAIChatMessages.AddUserMessage(Prompt);

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
        SystemPrompt.AppendLine('You are an AI assistant for a travel agency. You are asked to predict the capital of a country.');
        SystemPrompt.AppendLine('');
        SystemPrompt.AppendLine('IMPORTANT:');
        SystemPrompt.AppendLine('The answer should be the capital of the country, not the country itself.');
        SystemPrompt.AppendLine('You only predict the capital and nothing else.');
        exit(SystemPrompt.ToText());
    end;
}