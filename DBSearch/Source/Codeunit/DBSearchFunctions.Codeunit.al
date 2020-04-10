codeunit 50100 "DB Search Functions"
{
    Permissions = tabledata 17 = rmd, tabledata 18 = rmd, tabledata 21 = rmd, tabledata 23 = rmd, tabledata 24 = rmd, tabledata 25 = rmd, tabledata 27 = rmd, tabledata 32 = rmd, tabledata 36 = rmd, tabledata 37 = rmd, tabledata 38 = rmd, tabledata 39 = rmd, tabledata 98 = rmd, tabledata 112 = rmd, tabledata 113 = rmd, tabledata 114 = rmd, tabledata 115 = rmd, tabledata 122 = rmd, tabledata 123 = rmd, tabledata 124 = rmd, tabledata 125 = rmd, tabledata 169 = rmd, tabledata 253 = rmd, tabledata 254 = rmd, tabledata 336 = rmd, tabledata 337 = rmd, tabledata 355 = rmd, tabledata 379 = rmd, tabledata 380 = rmd, tabledata 1104 = rmd, tabledata 5050 = rmd, tabledata 5600 = rmd, tabledata 5601 = rmd, tabledata 5612 = rmd, tabledata 5802 = rmd, tabledata 7312 = rmd, tabledata 7318 = rmd, tabledata 7319 = rmd, tabledata 7322 = rmd, tabledata 7323 = rmd, tabledata 12114 = rmd, tabledata 12116 = rmd, tabledata 12142 = rmd, tabledata 12144 = rmd, tabledata 12147 = rmd, tabledata 12149 = rmd, tabledata 12171 = rmd, tabledata 12183 = rmd, tabledata 12184 = rmd, tabledata 110 = rmd, tabledata 111 = rmd, tabledata 120 = rmd, tabledata 121 = rmd, tabledata 271 = rmd, tabledata 5740 = rmd, tabledata 5741 = rmd, tabledata 5744 = rmd, tabledata 5745 = rmd, tabledata 6650 = rmd, tabledata 6651 = rmd, tabledata 7316 = rmd, tabledata 7317 = rmd, tabledata 7320 = rmd, tabledata 7321 = rmd;

    procedure CorrectValues(DBSearch: Record "DB Search")
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        OptionValue: Integer;
        OptionsQst: Label 'With validation,Without validation';
        Text001Txt: Label 'Correct selected values?';
        Text002Txt: Label 'Correction completed';
    begin
        OptionValue := Dialog.StrMenu(OptionsQst, 1, Text001Txt);
        if OptionValue = 0 then
            exit;

        with DBSearch do begin
            SetRange(Selected, true);
            if FindFirst() then begin
                repeat
                    // Skip the correction if value is equal to current field value
                    if "Current Value" <> "Correct Value" then begin
                        RecRef.Get("Record ID");
                        FldRef := RecRef.Field("Field No.");

                        OnBeforeCorrection();

                        // Modify the field with validation
                        if OptionValue = 1 then begin
                            Evaluate(FldRef, "Correct Value");
                            RecRef.Modify(true)
                        end else begin
                            // Modify the field without validation
                            FldRef.Value("Correct Value");
                            RecRef.Modify();
                        end;

                        OnAfterCorrection();

                        // Saves original record in ledger entries
                        SaveInLedgerEntries(DBSearch, DBSearchLedgEntry."Operation Type"::Modified);
                    end;

                    Delete();
                until (Next() = 0);

                Message(Text002Txt);
            end;
        end;
    end;

    procedure DeleteRecords(DBSearch: Record "DB Search")
    var
        RecRef: RecordRef;
        OptionValue: Integer;
        OptionsQst: Label 'With validation,Without validation';
        Text001Txt: Label 'Delete selected records?';
        Text002Txt: Label 'Deletion completed';
        Text003Txt: Label 'Are you VERY sure you want to proceed with the deletion of selected records? The operation cannot be undone. Make a backup of the database before continuing.';
    begin
        OptionValue := Dialog.StrMenu(OptionsQst, 2, Text001Txt);
        if OptionValue = 0 then
            exit;

        if not Confirm(Text001Txt) then exit;
        if not Confirm(Text001Txt) then exit;
        if not Confirm(Text001Txt) then exit;
        if not Confirm(Text003Txt) then exit;
        if not Confirm(Text003Txt) then exit;
        if not Confirm(Text003Txt) then exit;

        with DBSearch do begin
            SetRange(Selected, true);
            if FindFirst() then begin
                repeat
                    RecRef.GET("Record ID");

                    OnBeforeDelete();

                    // Delete the record with validation
                    if OptionValue = 1 then
                        RecRef.Delete(true)
                    else
                        // Delete the record without validation
                        RecRef.Delete();

                    OnAfterDelete();

                    // Save original record in ledger entries
                    SaveInLedgerEntries(DBSearch, DBSearchLedgEntry."Operation Type"::Deleted);

                    Delete();
                until (Next() = 0);

                Message(Text002Txt);
            end;
        end;
    end;

    procedure RestoreValue(DBSearchLedgEntry: Record "DB Search Ledger Entry")
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        OptionValue: Integer;
        OptionsQst: Label 'With validation,Without validation';
        Text001Txt: Label 'Restore selected value?';
        Text002Txt: Label 'Restore completed';
        Text003Txt: Label 'The value you are trying to restore has changed since you applied the correction. Continue?\\Current value: %1\Correction value: %2\Value to restore: %3';
    begin
        OptionValue := Dialog.StrMenu(OptionsQst, 1, Text001Txt);
        if OptionValue = 0 then
            exit;

        with DBSearchLedgEntry do
            IF "Operation Type" = "Operation Type"::Modified then begin
                RecRef.GET("Record ID");
                FldRef := RecRef.Field("Field No.");

                OnBeforeRestoreField();

                // Check if value has changed since the correction
                if Format(FldRef.Value) <> "Correct Value" then
                    if not Confirm(StrSubstNo(Text003Txt, FldRef.Value, "Correct Value", "Current Value")) then
                        exit;

                // Insert the original field value with validation
                if OptionValue = 1 then begin
                    Evaluate(FldRef, "Current Value");
                    RecRef.Modify(true);
                end else begin
                    // Insert the original field value without validation
                    FldRef.Value("Current Value");
                    RecRef.Modify();
                end;

                OnAfterRestoreField();

                // Update original record in ledger entries
                "Operation Type" := "Operation Type"::Restored;
                "Operation DateTime" := CURRENTDATETIME;
                Modify();

                Message(Text002Txt);
            end;
    end;

    procedure SearchValues()
    begin
        Report.RunModal(Report::"DB Search");
    end;

    procedure ShowRecord(RecId: RecordId)
    var
        RecRef: RecordRef;
        RecVar: Variant;
    begin
        RecRef := RecId.GetRecord();
        RecVar := RecRef;
        Page.Run(0, RecVar);
    end;

    local procedure SaveInLedgerEntries(DBSearch: Record "DB Search"; OptionType: Option)
    var
        DBSearchLedgEntry: Record "DB Search Ledger Entry";
        NextEntryNo: Integer;
    begin
        with DBSearchLedgEntry do begin
            if FindLast() then
                NextEntryNo := DBSearchLedgEntry."Entry No." + 10000
            else
                NextEntryNo := 10000;

            Reset();
            TransferFields(DBSearch);
            "Entry No." := NextEntryNo;
            "Operation Type" := OptionType;
            Insert(true);
        end;
    end;

    var
        DBSearchLedgEntry: Record "DB Search Ledger Entry";


    [IntegrationEvent(false, false)]
    local procedure OnBeforeCorrection()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCorrection()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDelete()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDelete()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRestoreField()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRestoreField()
    begin
    end;
}