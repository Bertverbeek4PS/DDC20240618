page 70105 "Customer Import"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Customer Import";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(CustomerNumber; Rec."Customer Number") { }
                field(Name; Rec."Name") { }
                field(Description; Rec.Description) { }
                field(beginDated; Rec."Begin Date") { }
                field(endDate; Rec."End Date") { }
            }
        }
    }
}