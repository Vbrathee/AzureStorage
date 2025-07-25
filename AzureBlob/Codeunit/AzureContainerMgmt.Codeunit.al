codeunit 88001 AzureContainermgmt
{
    trigger OnRun()
    begin

    end;

    procedure CreatAzureContainer(ContainerName: Text)
    var
        ABSContainerClient: Codeunit "ABS Container Client";
        Authorization: Interface "Storage Service Authorization";
        Response: Codeunit "ABS Operation Response";
        ABSContainerSetup: Record "ABS Container Acc setup";
        StorageServiceAuth: Codeunit "Storage Service Authorization";
    begin
        ABSContainerSetup.Get();
        Authorization := StorageServiceAuth.CreateSharedKey(ABSContainerSetup."Shared Access Key");
        ABSContainerClient.Initialize(ABSContainerSetup."Account Name", Authorization);
        Response := ABSContainerClient.CreateContainer(ContainerName);
        if Not Response.IsSuccessful() then
            Message(Response.GetError());
    end;

    procedure FindAzureContainer(ContainerName: Text): Boolean
    var
        ABSContainerClient: Codeunit "ABS Container Client";
        Authorization: Interface "Storage Service Authorization";
        Response: Codeunit "ABS Operation Response";
        ABSContainerSetup: Record "ABS Container Acc setup";
        StorageServiceAuth: Codeunit "Storage Service Authorization";
        ABSContainer: Record "ABS Container";
    begin
        ABSContainerSetup.Get();
        Authorization := StorageServiceAuth.CreateSharedKey(ABSContainerSetup."Shared Access Key");
        ABSContainerClient.Initialize(ABSContainerSetup."Account Name", Authorization);
        Response := ABSContainerClient.ListContainers(ABSContainer);
        if Response.IsSuccessful() then begin
            ABSContainer.SetRange(Name, ContainerName);
            if ABSContainer.FindFirst() then
                Exit(true)
            else
                exit(false);
        end else
            Message(Response.GetError());
    end;

    procedure DeleteAzureContainer(ContainerName: Text): Boolean
    var
        ABSContainerClient: Codeunit "ABS Container Client";
        Authorization: Interface "Storage Service Authorization";
        Response: Codeunit "ABS Operation Response";
        ABSContainerSetup: Record "ABS Container Acc setup";
        StorageServiceAuth: Codeunit "Storage Service Authorization";
        ABSContainer: Record "ABS Container";
    begin
        ABSContainerSetup.Get();
        Authorization := StorageServiceAuth.CreateSharedKey(ABSContainerSetup."Shared Access Key");
        ABSContainerClient.Initialize(ABSContainerSetup."Account Name", Authorization);
        Response := ABSContainerClient.DeleteContainer(ContainerName);
        if Response.IsSuccessful() then begin
            Message('Container %1 deleted Successfully', ContainerName);
        end else
            Message(Response.GetError());
    end;

    var
        myInt: Integer;
}