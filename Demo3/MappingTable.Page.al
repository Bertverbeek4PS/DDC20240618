page 70106 "Mapping Table"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "Mapping Table";
    InsertAllowed = false;
    DeleteAllowed = true;
    ModifyAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(ImportField; Rec.ImportField)
                {
                    ApplicationArea = All;
                }
                field(tableField; Rec.tableField)
                {
                    ApplicationArea = All;
                }
                field("Table Field Caption"; Rec."Table Field Caption")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}