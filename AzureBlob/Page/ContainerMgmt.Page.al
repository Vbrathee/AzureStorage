page 88006 "Container Management Test"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
    }

    actions
    {
        area(Processing)
        {
            action(CreateContainer)
            {
                ApplicationArea = All;


                trigger OnAction()
                var
                    ContainerManagement: Codeunit AzureContainermgmt;
                begin
                    ContainerSetup.Get();
                    ContainerManagement.CreatAzureContainer(ContainerSetup."Container Name");

                end;
            }
            action(ListContainer)
            {
                ApplicationArea = All;


                trigger OnAction()
                var
                    ContainerManagement: Codeunit AzureContainermgmt;
                begin
                    ContainerSetup.Get();
                    IF ContainerManagement.FindAzureContainer(ContainerSetup."Container Name") then
                        MESSAGE('Azure Container Mytest is Available')
                    else
                        MESSAGE('Azure Container Mytest is not Available');
                end;
            }
            action(DeleteContainer)
            {
                ApplicationArea = All;


                trigger OnAction()
                var
                    ContainerManagement: Codeunit AzureContainermgmt;
                begin
                    ContainerSetup.Get();
                    ContainerManagement.DeleteAzureContainer(ContainerSetup."Container Name");
                end;
            }
        }
    }

    var
        myInt: Integer;
        ContainerSetup: Record "ABS Container Acc setup";
}