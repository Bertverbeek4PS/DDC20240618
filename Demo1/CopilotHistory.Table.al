table 70103 "AI History 4PS"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
        }
        field(3; Tone; Enum "Entity Text Tone")
        {

        }
        field(4; TextFormat; Enum "Entity Text Format")
        {

        }
        field(5; Emphasis; Enum "Entity Text Emphasis")
        {

        }
        field(6; "Generated Text"; Blob)
        {

        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}