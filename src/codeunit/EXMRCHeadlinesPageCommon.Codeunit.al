codeunit 83202 "EXM RC Headlines Page Common"
{

    var
        Headlines: Codeunit Headlines;
        RCHeadlinesExecutor: Codeunit "RC Headlines Executor";
        DefaultFieldsVisible: Boolean;
        DocumentationTxt: Label 'Want to learn more about EXM?', Comment = 'ESP="Desea más información sobre EXM (Extension Manager)?"';
        GreetingText: Text[250];
        DocumentationText: Text[250];
        UserGreetingVisible: Boolean;

    procedure HeadlineOnOpenPage(RoleCenterPageID: Integer)
    var
        RCHeadlinesUserData: Record "RC Headlines User Data";
    begin
        if RCHeadlinesUserData.WritePermission() then begin
            if not RCHeadlinesUserData.Get(UserSecurityId(), RoleCenterPageID) then begin
                RCHeadlinesUserData.Init();
                RCHeadlinesUserData."Role Center Page ID" := RoleCenterPageID;
                RCHeadlinesUserData."User ID" := UserSecurityId();
                RCHeadlinesUserData.Insert();
            end;
            RCHeadlinesUserData."User workdate" := WorkDate();
            if ShouldCreateAComputeJob(RCHeadlinesUserData) then begin
                RCHeadlinesUserData."Last Computed" := CurrentDateTime();
                RCHeadlinesUserData.Modify();
                RCHeadlinesExecutor.ScheduleTask(RoleCenterPageID);
            end else
                RCHeadlinesUserData.Modify();
        end;
        GreetingText := CopyStr(Headlines.GetUserGreetingText(), 1, MaxStrLen(GreetingText));
        DocumentationText := DocumentationTxt;
        ComputeDefaultFieldsVisibility(RoleCenterPageID);

        Commit(); // not to mess up the other page parts that may do IF CODEUNIT.RUN()
    end;

    local procedure ShouldCreateAComputeJob(RCHeadlinesUserData: Record "RC Headlines User Data"): Boolean
    var
        OneHour: Duration;
    begin
        if RCHeadlinesUserData."Last Computed" = 0DT then
            exit(true);
        OneHour := 60 * 60 * 1000;
        exit(CurrentDateTime() - RCHeadlinesUserData."Last Computed" > OneHour);
    end;

    procedure ComputeDefaultFieldsVisibility(RoleCenterPageID: Integer)
    var
        ExtensionHeadlinesVisible: Boolean;
    begin
        OnIsAnyExtensionHeadlineVisible(ExtensionHeadlinesVisible, RoleCenterPageID);
        DefaultFieldsVisible := not ExtensionHeadlinesVisible;
        UserGreetingVisible := Headlines.ShouldUserGreetingBeVisible();
    end;

    procedure DocumentationUrlTxt(): Text
    begin
        exit('https://picazin.dev');
    end;

    procedure IsUserGreetingVisible(): Boolean
    begin
        exit(UserGreetingVisible);
    end;

    procedure GetGreetingText(): Text
    begin
        exit(GreetingText);
    end;

    procedure AreDefaultFieldsVisible(): Boolean
    begin
        exit(DefaultFieldsVisible);
    end;

    procedure GetDocumentationText(): Text
    begin
        exit(DocumentationText);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsAnyExtensionHeadlineVisible(var ExtensionHeadlinesVisible: Boolean; RoleCenterPageID: Integer)
    begin
    end;
}

