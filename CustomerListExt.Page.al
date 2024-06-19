pageextension 70101 CustomerListext extends "Customer List"
{
    actions
    {
        addlast(Prompting)
        {
            action(CopilotWeather)
            {
                ApplicationArea = All;
                Caption = 'Copilot capital';
                RunObject = page "Copilot Demo1";
                Image = Sparkle;
            }
            action(CopilotProposeduedate)
            {
                Caption = 'Propose due date';
                ApplicationArea = All;
                Image = Sparkle;

                trigger OnAction()
                var
                    Copilot: Page "Copilot Demo2";
                begin
                    Copilot.SetCustomerNo(Rec."No.");
                    Copilot.RunModal();
                end;
            }
            action(CopilotImport)
            {
                Caption = 'Import file';
                ApplicationArea = All;
                Image = SparkleFilled;

                trigger OnAction()
                var
                    Copilot: Page "Copilot Demo3";
                begin
                    Copilot.SetCustomerNo(Rec."No.");
                    Copilot.RunModal();
                end;
            }
        }
        addlast("&Customer")
        {
            action(ImportData)
            {
                ApplicationArea = All;
                Caption = 'Import Data';
                Image = Import;
                trigger OnAction()
                var
                    CustomerImport: Page "Customer Import";
                    Customerimporttable: Record "Customer Import";
                begin
                    Customerimporttable.SetRange("Customer Number", Rec."No.");
                    CustomerImport.SetTableView(Customerimporttable);
                    CustomerImport.Run();
                end;
            }
        }
    }
}