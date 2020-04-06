page 50101 "DBSearch Ledger Entries"
{
    PageType = Worksheet;
    SourceTable = "DB Search Ledger Entry";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Operation DateTime"; "Operation DateTime")
                {
                    ApplicationArea = All;
                }
                field("Operation Description"; "Operation Description")
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                }
                field("Current Value"; "Current Value")
                {
                    ApplicationArea = All;
                }
                field("Correct Value"; "Correct Value")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Restore)
            {
                ApplicationArea = All;
                Image = Restore;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin

                end;
            }
        }
    }
}
