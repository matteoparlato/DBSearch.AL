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
                field("Operation Description"; "Operation Type")
                {
                    StyleExpr = StyleExpression;
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
                Enabled = CanRestore;

                trigger OnAction()
                begin
                    DBSearchFunctions.RestoreValue(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CanRestore := false;
        case "Operation Type" of
            "Operation Type"::Deleted:
                begin
                    StyleExpression := 'Unfavorable';
                end;
            "Operation Type"::Modified:
                begin
                    StyleExpression := 'Unfavorable';
                    CanRestore := true;
                end else
                        StyleExpression := 'Favorable';
        end;
    end;

    var
        CanRestore: Boolean;
        DBSearchFunctions: Codeunit "DB Search Functions";
        StyleExpression: Text;
}
