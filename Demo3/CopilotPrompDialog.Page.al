page 70103 "Copilot Demo3"
{
    PageType = PromptDialog;
    Extensible = false;
    ApplicationArea = All;
    SourceTable = "Customer";
    SourceTableTemporary = true;
    Caption = 'Copilot Fps';
    IsPreview = true;


    layout
    {
        area(Prompt)
        {

            field(CustomerNo; Customer."No.")
            {
                ApplicationArea = All;
                Caption = 'Customer No.';
                Editable = false;
            }
            field(CustomerName; Customer."Name")
            {
                ApplicationArea = All;
                Caption = 'Customer Name';
                Editable = false;
            }
            field(filename; Filename)
            {
                ApplicationArea = All;
                Caption = 'Filename';
                Editable = false;
            }
        }
        area(Content)
        {
            part("Mapping Table"; "Mapping Table")
            {
                Caption = 'Mapping fields';
            }
            field(Response; Response)
            {
                ApplicationArea = All;
                Caption = 'Response';
                Editable = false;
                MultiLine = true;
            }
        }
    }

    actions
    {
        area(SystemActions)
        {
            systemaction(Generate)
            {
                Caption = 'Generate';
                trigger OnAction()
                var
                    CopilotDemo3: Codeunit "Copilot Demo3";
                begin
                    Response := CopilotDemo3.Generate(InStr);
                    processMappingFields(response);
                    CurrPage."Mapping Table".Page.SetTableView(MappingTable);
                    CurrPage.Update();
                end;
            }
            systemaction(OK)
            {
                Caption = 'Confirm';
                ToolTip = 'Add suggestion to the database.';
            }
            systemaction(Cancel)
            {
                Caption = 'Discard';
                ToolTip = 'Discard suggestion proposed by Dynamics 365 Copilot.';
            }
            systemaction(Regenerate)
            {
                Caption = 'Regenerate';
                ToolTip = 'Regenerate proposal with Dynamics 365 Copilot.';
                trigger OnAction()
                var
                    CopilotDemo3: Codeunit "Copilot Demo3";
                begin
                    Response := CopilotDemo3.Generate(InStr);
                    CurrPage.Update();
                end;
            }
            systemaction(Attach)
            {
                Caption = 'Attach a file';
                ToolTip = 'Upload a file to import.';
                trigger OnAction()
                begin
                    UploadIntoStream('Select a file...', '', 'All files (*.*)|*.*', Filename, InStr);
                end;
            }
        }
    }

    var
        Response: Text;
        CustomerNo: text;
        InStr: InStream;
        Filename: Text;
        Customer: Record "Customer";
        lCustomerImport: Record "Customer Import";
        CopilotDemo3: Codeunit "Copilot Demo3";
        MappingTable: Record "Mapping table";

    trigger OnOpenPage()
    begin
        Customer.Get(CustomerNo);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::Ok then begin
            CopilotDemo3.ProcessFile(Response, InStr);
        end;

        exit(true);
    end;

    internal procedure SetCustomerNo(_CustomerNo: Code[20])
    begin
        CustomerNo := _CustomerNo;
    end;

    local procedure processMappingFields(Result: Text)
    var
        XMLDoc: XmlDocument;
        XMLNodeList: XmlNodeList;
        XMLNode: XmlNode;
        ImportNode: XmlNode;
        TableNode: XmlNode;
        ImportXMLElem: XmlElement;
        TableXMLElem: XmlElement;
        Int: Integer;
    begin
        MappingTable.DeleteAll(); //just for the demo
        XmlDocument.ReadFrom(Result, XMLDoc);
        XMLDoc.SelectNodes('//mapping', XMLNodeList);
        foreach XMLNode in XMLNodeList do begin
            XMLNode.SelectSingleNode('importField', ImportNode);
            ImportXMLElem := ImportNode.AsXmlElement();
            XMLNode.SelectSingleNode('number', TableNode);
            TableXMLElem := TableNode.AsXmlElement();
            MappingTable.Init();
            MappingTable.ImportField := ImportXMLElem.InnerText;
            Evaluate(Int, TableXMLElem.InnerText);
            MappingTable."tableField" := Int + 1;
            MappingTable.Insert()
        end;
    end;
}