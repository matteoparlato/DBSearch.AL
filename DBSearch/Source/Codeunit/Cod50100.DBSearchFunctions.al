codeunit 50100 "DB Search Functions"
{
    procedure CorrectSearchValues(DBSearch: Record "DB Search")
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        Text001: TextConst ENU = 'Do you want to continue with the correction?', ITA = 'Vuoi procedere con la correzione?';
    begin
        if not Confirm(Text001) then
            exit;

        with DBSearch do begin
            FindFirst();
            repeat
                // Skip the correction if value is equal to current field value
                if "Current Value" <> "Correct Value" then begin
                    RecRef.Get("Record ID");
                    FldRef := RecRef.Field("Field No.");

                    Evaluate(FldRef, "Correct Value");

                    // Apply the correction to the field value
                    if not RecRef.Modify() then begin
                        RecRef.Insert();
                    end;
                    SaveToLedgerEntries(DBSearch);
                end;
            until (Next = 0);
        end;
    end;

    procedure DeleteSearchRecords()
    begin

    end;

    procedure FindSearchValues()
    begin

    end;

    procedure SaveToLedgerEntries(DBSearch: Record "DB Search")
    var
        DBSearchLedgEntry: Record "DB Search Ledger Entry";
    begin
        with DBSearchLedgEntry do begin
            TransferFields(DBSearch);
            "Creation DateTime" := CurrentDateTime;
            Insert();
        end;
    end;
}