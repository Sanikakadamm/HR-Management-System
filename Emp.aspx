<%@ Page Title="Employees" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Emp.aspx.cs" Inherits="HRMSProject.Emp" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .modal-backdrop { z-index: 1040 !important; }
        .modal { z-index: 1050 !important; }
        .modal-lg { max-width: 900px; }
        .emp-photo { width: 50px; height: 50px; object-fit: cover; border-radius: 50%; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

    <div class="container">
        <h2 class="my-4">Employee Management</h2>
        
        <button type="button" class="btn btn-primary mb-3" data-bs-toggle="modal" data-bs-target="#empModal">
            Add New Employee
        </button>

        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <asp:GridView ID="gvEmployees" runat="server" AutoGenerateColumns="false" CssClass="table table-bordered table-striped" OnRowCommand="gvEmployees_RowCommand" DataKeyNames="EmpID">
                    <Columns>
                        <asp:BoundField DataField="EmpID" HeaderText="ID" />
                        
                        <%-- Added Image Column --%>
                        <asp:TemplateField HeaderText="Photo">
                            <ItemTemplate>
                                <asp:Image ID="imgEmp" runat="server" 
                                    ImageUrl='<%# string.IsNullOrEmpty(Eval("ProfilePhotoPath").ToString()) ? "~/Images/default-avatar.png" : Eval("ProfilePhotoPath") %>' 
                                    CssClass="emp-photo" />
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="FullName" HeaderText="Name" />
                        <asp:BoundField DataField="Email" HeaderText="Email" />
                        <asp:BoundField DataField="DeptName" HeaderText="Department" />
                        <asp:BoundField DataField="DesigName" HeaderText="Designation" />
                        <asp:BoundField DataField="RoleName" HeaderText="Role" />
                        <asp:BoundField DataField="ManagerName" HeaderText="Manager" />
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <%# Convert.ToBoolean(Eval("IsActive")) ? "<span class='badge bg-success'>Active</span>" : "<span class='badge bg-danger'>Inactive</span>" %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Action">
                            <ItemTemplate>
                                <div class="d-flex gap-2">
                                    <asp:LinkButton ID="btnEdit" runat="server" Text="Edit" CommandName="EditRow" 
                                        CommandArgument='<%# Eval("EmpID") %>' CssClass="btn btn-sm btn-warning" />
                                    
                                    <asp:LinkButton ID="btnDelete" runat="server" Text="Delete" CommandName="DeleteRow" 
                                        CommandArgument='<%# Eval("EmpID") %>' CssClass="btn btn-sm btn-danger" 
                                        OnClientClick="return confirm('Are you sure you want to delete this employee?');" />
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
            <div class="modal fade" id="empModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title">Employee Details</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <asp:HiddenField ID="hfEmpID" runat="server" />
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Full Name</label>
                                    <asp:TextBox ID="txtName" runat="server" CssClass="form-control" required></asp:TextBox>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Email</label>
                                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" required></asp:TextBox>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Contact</label>
                                    <asp:TextBox ID="txtContact" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Address</label>
                                    <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="1"></asp:TextBox>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Password</label>
                                    <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" required></asp:TextBox>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Role</label>
                                    <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-select" onchange="toggleFields(this.options[this.selectedIndex].text);" required>
                                    </asp:DropDownList>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Department</label>
                                    <asp:DropDownList ID="ddlDept" runat="server" CssClass="form-select"></asp:DropDownList>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Designation</label>
                                    <asp:DropDownList ID="ddlDesig" runat="server" CssClass="form-select"></asp:DropDownList>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Manager</label>
                                    <asp:DropDownList ID="ddlManager" runat="server" CssClass="form-select"></asp:DropDownList>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Status</label>
                                    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select">
                                        <asp:ListItem Value="True">Active</asp:ListItem>
                                        <asp:ListItem Value="False">Inactive</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-12 mb-3">
                                    <label class="form-label">Profile Photo</label>
                                    <asp:FileUpload ID="fuPhoto" runat="server" CssClass="form-control" />
                                </div>
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
            <asp:PostBackTrigger ControlID="btnSave" />
            <asp:AsyncPostBackTrigger ControlID="gvEmployees" EventName="RowCommand" />
        </Triggers>
    </asp:UpdatePanel>
    
    <script type="text/javascript">
        function openModal() {
            var myModal = new bootstrap.Modal(document.getElementById('empModal'), {
                keyboard: false
            });
            myModal.show();
        }

        function toggleFields(roleName) {
            var dept = document.getElementById('<%= ddlDept.ClientID %>');
            var desig = document.getElementById('<%= ddlDesig.ClientID %>');
            var manager = document.getElementById('<%= ddlManager.ClientID %>');

            // Reset
            dept.disabled = false;
            desig.disabled = false;
            manager.disabled = false;

            if (roleName === 'Admin') {
                dept.disabled = true;
                desig.disabled = true;
                manager.disabled = true;
            } else if (roleName === 'Manager') {
                manager.disabled = true;
            }
        }
    </script>
</asp:Content>
