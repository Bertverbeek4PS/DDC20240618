table 70101 "Customer Import"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Number; Integer)
        {
        }
        field(2; "Customer Number"; Code[20])
        {
        }
        field(3; "Name"; Text[100])
        {
        }
        field(4; "Description"; Text[100])
        {
        }
        field(5; "Begin Date"; Date)
        {
        }
        field(6; "End Date"; Date)
        {
        }
    }

    keys
    {
        key(Key1; Number)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}