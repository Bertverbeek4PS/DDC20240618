table 70102 "Mapping table"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; ImportField; Text[100])
        {
            Editable = false;
        }
        field(2; "tableField"; Integer)
        {
            Caption = 'Table Field';
            DataClassification = ToBeClassified;
            TableRelation = Field."No." where(TableNo = const(Database::"Customer Import"));
        }
        field(3; "Table Field Caption"; Text[100])
        {
            CalcFormula = lookup(Field."Field Caption" where(TableNo = const(Database::"Customer Import"),
                                                             "No." = field("tableField")));
            Caption = 'Table Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; ImportField)
        {
            Clustered = true;
        }
    }
}