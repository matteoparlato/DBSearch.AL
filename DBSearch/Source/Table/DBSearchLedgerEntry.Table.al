table 50101 "DB Search Ledger Entry"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
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
        field(4; "Table Name"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Table Name';
        }
        field(5; "Field No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Field No.';
        }
        field(6; "Field Name"; Text[50])
        {
            Caption = 'Field Name';
            DataClassification = CustomerContent;
        }
        field(7; "Current Value"; Text[250])
        {
            Caption = 'Previous Value';
            DataClassification = CustomerContent;
        }
        field(8; "Correct Value"; Text[250])
        {
            Caption = 'Correct Value';
            DataClassification = CustomerContent;
        }
        field(101; "Operation Type"; Option)
        {
            Caption = 'Operation Type';
            OptionMembers = Deleted,Modified,Restored;
            DataClassification = CustomerContent;
        }
        field(102; "Operation DateTime"; DateTime)
        {
            Caption = 'Operation DateTime';
            DataClassification = CustomerContent;
        }
        field(103; "Operation Executed By"; Code[50])
        {
            Caption = 'Operation Executed By';
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


    trigger OnInsert()
    begin
        "Operation DateTime" := CurrentDateTime;
        "Operation Executed By" := CopyStr(UserId, 1, 50);
    end;
}