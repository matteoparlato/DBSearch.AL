report 50100 "DB Search"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem(Field; Field)
        {
            trigger OnAfterGetRecord()
            begin
                FindSearchValues();
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
                    field(txtFindString; SearchPattern)
                    {
                        Caption = 'Text to search';
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

        trigger OnOpenPage()
        var
            Tip: Notification;
        begin
            Field.SETFILTER(Type, '%1|%2', Field.Type::Code, Field.Type::Text);
            Field.SETRANGE(Class, Field.Class::Normal);
            Field.SETRANGE(Enabled, TRUE);
            field.SetFilter(ObsoleteState, '%1|%2', Field.ObsoleteState::No, Field.ObsoleteState::Pending);
            Field.SETFILTER(Len, '>=10');
            Field.SETFILTER(TableNo, '(<5340|>5372)&(<6701|>6721)&(<18008020|>18008035)');

            Tip.Message := 'Tip: You can use special symbols (or operators) to further filter the results.';
            Tip.Scope := NotificationScope::LocalScope;
            Tip.Send();
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if CloseAction = Action::OK then
                CheckPassword();
        end;
    }

    [NonDebuggable]
    local procedure CheckPassword()
    var
        Text0001: TextConst ENU = 'The specified password is not correct.', ITA = 'La password specificata non è corretta';
    begin
        if Password <> 'a8a0c8e9-bdc8-4719-9e3b-3114328830af' then begin
            Error(Text0001);
        end;
    end;

    local procedure FindSearchValues()
    var
        rrSearchValuesField: RecordRef;
        rrSearchValuesFieldTmp: RecordRef;
        frFieldEntryNo: FieldRef;
        frFieldRecordID: FieldRef;
        frFieldTabNo: FieldRef;
        frTableName: FieldRef;
        frFieldFieldNo: FieldRef;
        frFieldName: FieldRef;
        frFieldCurrValue: FieldRef;
        frFieldNewValue: FieldRef;
        LrecField: Record Field;
        LrecField2: Record Field;
        nCount: Integer;
        nRecord: Integer;
        nThisRecNo: Integer;
        window: Dialog;
        recDBSearcher: Record "DB Search";
        frField: FieldRef;
        rrTab: RecordRef;
        txtOldValue: Text;
    begin
        LrecField.COPYFILTERS(Field);
        nThisRecNo := DATABASE::"DB Search";
        WITH recDBSearcher DO BEGIN
            IF FINDLAST THEN BEGIN
                nCount := "Entry No.";
            END ELSE
                nCount := 0;
            nRecord := 0;

            window.OPEN('Tab: ' + '############1\' + 'Rec: ' + '############2', LrecField.TableNo, nRecord);

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
            LrecField.SetRange(ObsoleteState, LrecField.ObsoleteState::No, LrecField.ObsoleteState::Pending);
            IF LrecField.FIND('-') THEN
                REPEAT
                    IF LrecField.TableNo <> nThisRecNo THEN BEGIN
                        nRecord := 0;
                        rrTab.OPEN(LrecField.TableNo);
                        frField := rrTab.FIELD(LrecField."No.");
                        frField.SETFILTER(SearchPattern);
                        IF rrTab.FIND('-') THEN
                            REPEAT
                                nRecord += 1;

                                window.UPDATE(1, LrecField.TableNo);
                                window.UPDATE(2, nRecord);
                                frField := rrTab.FIELD(LrecField."No.");
                                txtOldValue := FORMAT(frField.VALUE);
                                frFieldTabNo.VALUE(LrecField.TableNo);
                                frTableName.VALUE(LrecField.TableName);
                                frFieldFieldNo.VALUE(LrecField."No.");
                                frFieldName.VALUE(LrecField.FieldName);
                                EVALUATE(frFieldCurrValue, txtOldValue);
                                frFieldRecordID.VALUE(rrTab.RECORDID);
                                EVALUATE(frFieldNewValue, txtOldValue);
                                nCount += 1;
                                frFieldEntryNo.VALUE(nCount);
                                rrSearchValuesFieldTmp.INSERT;
                            UNTIL rrTab.NEXT = 0;
                        rrTab.CLOSE;
                    END;
                UNTIL LrecField.NEXT = 0;
            window.CLOSE;
            rrSearchValuesFieldTmp.CLOSE;
        END;

    end;

    var
        SearchPattern: Text[1024];
        Password: Text[36];
}