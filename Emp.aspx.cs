using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;
using System.Configuration;
using System.Web.UI;
using System.IO;

namespace HRMSProject
{
    public partial class Emp : System.Web.UI.Page
    {
        string conString = ConfigurationManager.ConnectionStrings["MyCon"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateDropdowns();
                BindGrid();
            }
        }

        private void PopulateDropdowns()
        {
            using (SqlConnection con = new SqlConnection(conString))
            {
                con.Open();

                // 1. Departments
                SqlDataAdapter daDept = new SqlDataAdapter("SELECT DeptID, DeptName FROM Dept WHERE IsActive = 1", con);
                DataTable dtDept = new DataTable();
                daDept.Fill(dtDept);
                ddlDept.DataSource = dtDept;
                ddlDept.DataTextField = "DeptName";
                ddlDept.DataValueField = "DeptID";
                ddlDept.DataBind();
                ddlDept.Items.Insert(0, new ListItem("-- Select Department --", "0"));

                // 2. Designations
                SqlDataAdapter daDesig = new SqlDataAdapter("SELECT DesigID, DesigName FROM Designation WHERE IsActive = 1", con);
                DataTable dtDesig = new DataTable();
                daDesig.Fill(dtDesig);
                ddlDesig.DataSource = dtDesig;
                ddlDesig.DataTextField = "DesigName";
                ddlDesig.DataValueField = "DesigID";
                ddlDesig.DataBind();
                ddlDesig.Items.Insert(0, new ListItem("-- Select Designation --", "0"));

                // 3. Roles
                SqlDataAdapter daRole = new SqlDataAdapter("SELECT RoleID, RoleName FROM Roles WHERE IsActive = 1", con);
                DataTable dtRole = new DataTable();
                daRole.Fill(dtRole);
                ddlRole.DataSource = dtRole;
                ddlRole.DataTextField = "RoleName";
                ddlRole.DataValueField = "RoleID";
                ddlRole.DataBind();
                ddlRole.Items.Insert(0, new ListItem("-- Select Role --", "0"));

                // 4. Managers
                SqlDataAdapter daMgr = new SqlDataAdapter("SELECT MID, MName FROM Manager", con);
                DataTable dtMgr = new DataTable();
                daMgr.Fill(dtMgr);
                ddlManager.DataSource = dtMgr;
                ddlManager.DataTextField = "MName";
                ddlManager.DataValueField = "MID";
                ddlManager.DataBind();
                ddlManager.Items.Insert(0, new ListItem("-- Select Manager --", "0"));
            }
        }

        private void BindGrid()
        {
            using (SqlConnection con = new SqlConnection(conString))
            {
                // Ensure sp_GetEmp selects ProfilePhotoPath
                SqlCommand cmd = new SqlCommand("sp_GetEmp", con);
                cmd.CommandType = CommandType.StoredProcedure;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvEmployees.DataSource = dt;
                gvEmployees.DataBind();
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string photoPath = "";
            if (fuPhoto.HasFile)
            {
                // Ensure 'Uploads' folder exists in project
                string filename = Path.GetFileName(fuPhoto.PostedFile.FileName);
                photoPath = "~/Uploads/" + filename;
                fuPhoto.SaveAs(Server.MapPath(photoPath));
            }

            using (SqlConnection con = new SqlConnection(conString))
            {
                con.Open();
                SqlCommand cmd;

                bool isAdmin = ddlRole.SelectedItem.Text == "Admin";

                if (string.IsNullOrEmpty(hfEmpID.Value))
                {
                    cmd = new SqlCommand("sp_InsertEmp", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Name", txtName.Text);
                    cmd.Parameters.AddWithValue("@Email", txtEmail.Text);
                    cmd.Parameters.AddWithValue("@Contact", txtContact.Text);
                    cmd.Parameters.AddWithValue("@Address", txtAddress.Text);
                    cmd.Parameters.AddWithValue("@Password", txtPassword.Text);
                    cmd.Parameters.AddWithValue("@DeptID", isAdmin ? DBNull.Value : (object)ddlDept.SelectedValue);
                    cmd.Parameters.AddWithValue("@DesigID", isAdmin ? DBNull.Value : (object)ddlDesig.SelectedValue);
                    cmd.Parameters.AddWithValue("@RoleID", ddlRole.SelectedValue);
                    cmd.Parameters.AddWithValue("@ManagerID", (isAdmin || ddlRole.SelectedItem.Text == "Manager" || ddlManager.SelectedValue == "0") ? DBNull.Value : (object)ddlManager.SelectedValue);
                    cmd.Parameters.AddWithValue("@IsActive", Convert.ToBoolean(ddlStatus.SelectedValue));
                    // Using ProfilePhotoPath as discussed
                    cmd.Parameters.AddWithValue("@ProfilePhotoPath", string.IsNullOrEmpty(photoPath) ? DBNull.Value : (object)photoPath);
                }
                else
                {
                    cmd = new SqlCommand("sp_UpdateEmp", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@EmpID", hfEmpID.Value);
                    cmd.Parameters.AddWithValue("@Name", txtName.Text);
                    cmd.Parameters.AddWithValue("@Email", txtEmail.Text);
                    cmd.Parameters.AddWithValue("@Contact", txtContact.Text);
                    cmd.Parameters.AddWithValue("@Address", txtAddress.Text);
                    cmd.Parameters.AddWithValue("@Password", txtPassword.Text);
                    cmd.Parameters.AddWithValue("@DeptID", isAdmin ? DBNull.Value : (object)ddlDept.SelectedValue);
                    cmd.Parameters.AddWithValue("@DesigID", isAdmin ? DBNull.Value : (object)ddlDesig.SelectedValue);
                    cmd.Parameters.AddWithValue("@RoleID", ddlRole.SelectedValue);
                    cmd.Parameters.AddWithValue("@ManagerID", (isAdmin || ddlRole.SelectedItem.Text == "Manager" || ddlManager.SelectedValue == "0") ? DBNull.Value : (object)ddlManager.SelectedValue);
                    cmd.Parameters.AddWithValue("@IsActive", Convert.ToBoolean(ddlStatus.SelectedValue));

                    if (photoPath != "")
                        cmd.Parameters.AddWithValue("@ProfilePhotoPath", photoPath);
                    else
                        cmd.Parameters.AddWithValue("@ProfilePhotoPath", DBNull.Value);
                }

                cmd.ExecuteNonQuery();
                con.Close();

                // Clear fields
                hfEmpID.Value = "";
                txtName.Text = "";
                txtEmail.Text = "";
                txtContact.Text = "";
                txtAddress.Text = "";
                txtPassword.Text = "";
                ddlDept.SelectedIndex = 0;
                ddlDesig.SelectedIndex = 0;
                ddlRole.SelectedIndex = 0;
                ddlManager.SelectedIndex = 0;
                BindGrid();
            }
        }

        protected void gvEmployees_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteRow")
            {
                int empID = Convert.ToInt32(e.CommandArgument);
                using (SqlConnection con = new SqlConnection(conString))
                {
                    SqlCommand cmd = new SqlCommand("sp_DeleteEmp", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@EmpID", empID);
                    con.Open();
                    cmd.ExecuteNonQuery();
                    con.Close();
                    BindGrid();
                }
            }
            else if (e.CommandName == "EditRow")
            {
                int empID = Convert.ToInt32(e.CommandArgument);
                using (SqlConnection con = new SqlConnection(conString))
                {
                    SqlCommand cmd = new SqlCommand("SELECT * FROM Employee WHERE EmpID = @EmpID", con);
                    cmd.Parameters.AddWithValue("@EmpID", empID);
                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        hfEmpID.Value = dr["EmpID"].ToString();
                        txtName.Text = dr["Name"].ToString();
                        txtEmail.Text = dr["Email"].ToString();
                        txtContact.Text = dr["Contact"].ToString();
                        txtAddress.Text = dr["Address"].ToString();
                        txtPassword.Text = dr["Password"].ToString();
                        ddlRole.SelectedValue = dr["RoleID"].ToString();

                        if (dr["DeptID"] != DBNull.Value) ddlDept.SelectedValue = dr["DeptID"].ToString();
                        if (dr["DesigID"] != DBNull.Value) ddlDesig.SelectedValue = dr["DesigID"].ToString();
                        if (dr["ManagerID"] != DBNull.Value) ddlManager.SelectedValue = dr["ManagerID"].ToString();

                        ddlStatus.SelectedValue = dr["IsActive"].ToString();

                        string roleName = ddlRole.SelectedItem.Text;
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "Toggle", $"toggleFields('{roleName}');", true);
                    }
                    con.Close();
                }

                ScriptManager.RegisterStartupScript(this, this.GetType(), "Pop", "openModal();", true);
            }
        }
    }
}
