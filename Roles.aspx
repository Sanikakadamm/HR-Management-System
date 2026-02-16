<%@ Page Title="Roles" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Roles.aspx.cs" Inherits="HRMSProject.Roles" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .modal-backdrop { z-index: 1040 !important; }
        .modal { z-index: 1050 !important; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

    <div class="container">
        <h2 class="my-4">Role Management</h2>
        
        <button type="button" class="btn btn-primary mb-3" data-bs-toggle="modal" data-bs-target="#roleModal">
            Add New Role
        </button>

        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <asp:GridView ID="gvRoles" runat="server" AutoGenerateColumns="false" CssClass="table table-bordered table-striped" OnRowCommand="gvRoles_RowCommand" DataKeyNames="RoleID">
                    <Columns>
                        <asp:BoundField DataField="RoleID" HeaderText="ID" />
                        <asp:BoundField DataField="RoleName" HeaderText="Role Name" />
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <%# Convert.ToBoolean(Eval("IsActive")) ? "<span class='badge bg-success'>Active</span>" : "<span class='badge bg-danger'>Inactive</span>" %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Action">
                            <ItemTemplate>
                                <div class="d-flex gap-2">
                                    <asp:LinkButton ID="btnEdit" runat="server" Text="Edit" CommandName="EditRow" 
                                        CommandArgument='<%# Eval("RoleID") %>' CssClass="btn btn-sm btn-warning" />
                                    
                                    <asp:LinkButton ID="btnDelete" runat="server" Text="Delete" CommandName="DeleteRow" 
                                        CommandArgument='<%# Eval("RoleID") %>' CssClass="btn btn-sm btn-danger" 
                                        OnClientClick="return confirm('Are you sure you want to delete this?');" />
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>

    <asp:UpdatePanel ID="UpdatePanel2" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <div class="modal fade" id="roleModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title">Role Details</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <asp:HiddenField ID="hfRoleID" runat="server" />
                            <div class="mb-3">
                                <label class="form-label">Role Name</label>
                                <asp:TextBox ID="txtRoleName" runat="server" CssClass="form-control" required></asp:TextBox>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Status</label>
                                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="True">Active</asp:ListItem>
                                    <asp:ListItem Value="False">Inactive</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                            <asp:Button ID="btnSave" runat="server" Text="Save Changes" CssClass="btn btn-primary" OnClick="btnSave_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvRoles" EventName="RowCommand" />
        </Triggers>
    </asp:UpdatePanel>
    
    <script type="text/javascript">
        function openModal() {
            var myModal = new bootstrap.Modal(document.getElementById('roleModal'), {
                keyboard: false
            });
            myModal.show();
        }
    </script>
</asp:Content>
