<%@ Page Title="Designations" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Designation.aspx.cs" Inherits="HRMSProject.Designation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .modal-backdrop { z-index: 1040 !important; }
        .modal { z-index: 1050 !important; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

    <div class="container">
        <h2 class="my-4">Designation Management</h2>
        
        <button type="button" class="btn btn-primary mb-3" data-bs-toggle="modal" data-bs-target="#desigModal">
            Add New Designation
        </button>

        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <asp:GridView ID="gvDesig" runat="server" AutoGenerateColumns="false" CssClass="table table-bordered table-striped" OnRowCommand="gvDesig_RowCommand" DataKeyNames="DesigID">
                    <Columns>
                        <asp:BoundField DataField="DesigID" HeaderText="ID" />
                        <asp:BoundField DataField="DeptName" HeaderText="Department" />
                        <asp:BoundField DataField="DesigName" HeaderText="Designation" />
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <%# Convert.ToBoolean(Eval("IsActive")) ? "<span class='badge bg-success'>Active</span>" : "<span class='badge bg-danger'>Inactive</span>" %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Action">
                            <ItemTemplate>
                                <div class="d-flex gap-2">
                                    <asp:LinkButton ID="btnEdit" runat="server" Text="Edit" CommandName="EditRow" 
                                        CommandArgument='<%# Eval("DesigID") %>' CssClass="btn btn-sm btn-warning" />
                                    
                                    <asp:LinkButton ID="btnDelete" runat="server" Text="Delete" CommandName="DeleteRow" 
                                        CommandArgument='<%# Eval("DesigID") %>' CssClass="btn btn-sm btn-danger" 
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
            <div class="modal fade" id="desigModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title">Designation Details</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <asp:HiddenField ID="hfDesigID" runat="server" />
                            
                            <div class="mb-3">
                                <label class="form-label">Department</label>
                                <asp:DropDownList ID="ddlDept" runat="server" CssClass="form-select" required></asp:DropDownList>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Designation Name</label>
                                <asp:TextBox ID="txtDesigName" runat="server" CssClass="form-control" required></asp:TextBox>
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
            <asp:AsyncPostBackTrigger ControlID="gvDesig" EventName="RowCommand" />
        </Triggers>
    </asp:UpdatePanel>
    
    <script type="text/javascript">
        function openModal() {
            var myModal = new bootstrap.Modal(document.getElementById('desigModal'), {
                keyboard: false
            });
            myModal.show();
        }
    </script>
</asp:Content>
