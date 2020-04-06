report 50100 "DB Search"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem(Field; Field)
        {
            trigger OnAfterGetRecord()
            var
                LrecField: Record Field;
                LrecField2: Record Field;
                nThisRecNo: Integer;
                ProgressDialog: Dialog;
                NumberOfRecords: Integer;
                RecordCount: Integer;
                frFieldEntryNo: FieldRef;
                frFieldRecordID: FieldRef;
                frFieldTabNo: FieldRef;
                frTableName: FieldRef;
                frFieldFieldNo: FieldRef;
                frFieldName: FieldRef;
                frFieldCurrValue: FieldRef;
                frFieldNewValue: FieldRef;
                rrSearchValuesFieldTmp: RecordRef;
                recDBSearcher: Record "DB Search";
                frField: FieldRef;
                rrTab: RecordRef;
                txtOldValue: Text[1024];
            begin
                LrecField.COPYFILTERS(Field);
                nThisRecNo := DATABASE::"DB Search";
                WITH recDBSearcher DO BEGIN
                    IF FINDLAST THEN BEGIN
                        RecordCount := "Entry No.";
                    END ELSE
                        RecordCount := 0;
                    NumberOfRecords := 0;
                    ProgressDialog.OPEN('Tab: ' + '############1\' +
                                'Rec: ' + '############2', LrecField.TableNo, NumberOfRecords);

                    rrSearchValuesFieldTmp.OPEN(nThisRecNo);
                    frFieldEntryNo := rrSearchValuesFieldTmp.FIELD(1);
                    frFieldRecordID := rrSearchValuesFieldTmp.FIELD(2);
                    frFieldTabNo := rrSearchValuesFieldTmp.FIELD(3);
                    frTableName := rrSearchValuesFieldTmp.FIELD(4);
                    frFieldFieldNo := rrSearchValuesFieldTmp.FIELD(5);
                    frFieldName := rrSearchValuesFieldTmp.FIELD(6);
                    frFieldCurrValue := rrSearchValuesFieldTmp.FIELD(7);
                    frFieldNewValue := rrSearchValuesFieldTmp.FIELD(8);

                    IF LrecField.GETFILTER(TableNo) <> '' THEN
                        LrecField.SETFILTER(TableNo, '1..1000000000&' + LrecField.GETFILTER(TableNo))
                    ELSE
                        LrecField.SETFILTER(TableNo, '1..1000000000');
                    LrecField.SETRANGE(Enabled, TRUE);
                    IF LrecField.FIND('-') THEN
                        REPEAT
                            IF LrecField.TableNo <> nThisRecNo THEN BEGIN
                                NumberOfRecords := 0;
                                rrTab.OPEN(LrecField.TableNo);
                                frField := rrTab.FIELD(LrecField."No.");
                                BEGIN
                                    frField.SETFILTER(txtFindString);
                                    IF rrTab.FIND('-') THEN
                                        REPEAT
                                            NumberOfRecords += 1;
                                            ProgressDialog.UPDATE(1, LrecField.TableNo);
                                            ProgressDialog.UPDATE(2, NumberOfRecords);
                                            frField := rrTab.FIELD(LrecField."No.");
                                            txtOldValue := FORMAT(frField.VALUE);
                                            frFieldTabNo.VALUE(LrecField.TableNo);
                                            frTableName.VALUE(LrecField.TableName);
                                            frFieldFieldNo.VALUE(LrecField."No.");
                                            frFieldName.VALUE(LrecField.FieldName);
                                            EVALUATE(frFieldCurrValue, txtOldValue);
                                            frFieldRecordID.VALUE(rrTab.RECORDID);
                                            EVALUATE(frFieldNewValue, txtOldValue);
                                            IF txtCorrectValue <> '' THEN
                                                IF txtCorrectValue = '''''' THEN
                                                    frFieldNewValue.VALUE := ''
                                                ELSE
                                                    frFieldNewValue.VALUE := txtCorrectValue;
                                            IF txtOldValue <> '' THEN BEGIN
                                                IF txtFieldToCorrect <> '' THEN BEGIN
                                                    LrecField2.SETRANGE(TableNo, LrecField.TableNo);
                                                    LrecField2.SETRANGE(Enabled, TRUE);
                                                    LrecField2.SETFILTER(FieldName, txtFieldToCorrect);
                                                    IF LrecField2.FINDFIRST THEN
                                                        REPEAT
                                                            frField := rrTab.FIELD(LrecField2."No.");
                                                            IF txtCorrectValue = '''''' THEN
                                                                frFieldNewValue.VALUE := ''
                                                            ELSE
                                                                frFieldNewValue.VALUE := txtCorrectValue;
                                                            RecordCount += 1;
                                                            frFieldEntryNo.VALUE(RecordCount);
                                                            rrSearchValuesFieldTmp.INSERT;
                                                        UNTIL LrecField2.NEXT = 0;
                                                END ELSE BEGIN
                                                    RecordCount += 1;
                                                    frFieldEntryNo.VALUE(RecordCount);
                                                    rrSearchValuesFieldTmp.INSERT;
                                                END;
                                            END;
                                        UNTIL rrTab.NEXT = 0;
                                END;
                                rrTab.CLOSE;
                            END;
                        UNTIL LrecField.NEXT = 0;
                    ProgressDialog.CLOSE;
                    rrSearchValuesFieldTmp.CLOSE;
                END;
                CurrReport.Break();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field(txtFindString; txtFindString)
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            FIeld.SetRange(Len, StrLen(txtFindString));
                        end;
                    }
                    field(txtFieldToCorrect; txtFieldToCorrect)
                    {
                        ApplicationArea = All;
                    }
                    field(txtCorrectValue; txtCorrectValue)
                    {
                        ApplicationArea = All;
                    }
                    field(Password; Password)
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }


        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if CloseAction = Action::OK then
                CheckPassword();
        end;
    }

    [NonDebuggable]
    local procedure CheckPassword()
    begin
        if Password <> 'a8a0c8e9-bdc8-4719-9e3b-3114328830af' then begin
            Error(Text0001);
        end;
    end;

    var
        txtFindString: Text[1024];
        txtFieldToCorrect: Text[250];
        txtCorrectValue: Text[1024];
        Password: Text[36];
        Text0001: TextConst ENU = 'The specified password is not correct.', ITA = 'La password specificata non è corretta';

}