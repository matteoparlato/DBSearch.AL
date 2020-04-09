table 50100 "DB Search"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
        }
        field(2; "Record ID"; RecordId)
        {
            DataClassification = CustomerContent;
            Caption = 'Record ID';
        }
        field(3; "Table No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table No.';
        }
        field(4; "Table Name"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Table Name';
        }
        field(5; "Field No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Field No.';
        }
        field(6; "Field Name"; Text[80])
        {
            Caption = 'Field Name';
            DataClassification = CustomerContent;
        }
        field(7; "Current Value"; Text[2048])
        {
            Caption = 'Current Value';
            DataClassification = CustomerContent;
        }
        field(8; "Correct Value"; Text[2048])
        {
            Caption = 'Correct Value';
            DataClassification = CustomerContent;
        }
        field(100; Selected; Boolean)
        {
            Caption = 'Selected';
            DataClassification = CustomerContent;
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