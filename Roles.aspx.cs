using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;
using System.Configuration;
using System.Web.UI;

namespace HRMSProject
{
    public partial class Roles : System.Web.UI.Page
    {
        string conString = ConfigurationManager.ConnectionStrings["MyCon"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindGrid();
            }
        }

        private void BindGrid()
        {
            using (SqlConnection con = new SqlConnection(conString))
            {
                // Ensure sp_GetRoles exists
                SqlCommand cmd = new SqlCommand("sp_GetRole", con);
                cmd.CommandType = CommandType.StoredProcedure;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvRoles.DataSource = dt;
                gvRoles.DataBind();
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            using (SqlConnection con = new SqlConnection(conString))
            {
                con.Open();
                SqlCommand cmd;

                if (string.IsNullOrEmpty(hfRoleID.Value))
                {
                    // Ensure sp_InsertRole exists
                    cmd = new SqlCommand("sp_InsertRole", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@RoleName", txtRoleName.Text);
                    cmd.Parameters.AddWithValue("@IsActive", Convert.ToBoolean(ddlStatus.SelectedValue));
                }
                else
                {
                    // Ensure sp_UpdateRole exists
                    cmd = new SqlCommand("sp_UpdateRole", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@RoleID", hfRoleID.Value);
                    cmd.Parameters.AddWithValue("@RoleName", txtRoleName.Text);
                    cmd.Parameters.AddWithValue("@IsActive", Convert.ToBoolean(ddlStatus.SelectedValue));
                }

                cmd.ExecuteNonQuery();
                con.Close();

                hfRoleID.Value = "";
                txtRoleName.Text = "";
                BindGrid();
            }
        }

        protected void gvRoles_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteRow")
            {
                int roleID = Convert.ToInt32(e.CommandArgument);
                using (SqlConnection con = new SqlConnection(conString))
                {
                    // Ensure sp_DeleteRole exists
                    SqlCommand cmd = new SqlCommand("sp_DeleteRole", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@RoleID", roleID);
                    con.Open();
                    cmd.ExecuteNonQuery();
                    con.Close();
                    BindGrid();
                }
            }
            else if (e.CommandName == "EditRow")
            {
                int roleID = Convert.ToInt32(e.CommandArgument);
                using (SqlConnection con = new SqlConnection(conString))
                {
                    // Direct query to fetch row for editing
                    SqlCommand cmd = new SqlCommand("SELECT RoleID, RoleName, IsActive FROM Roles WHERE RoleID = @RoleID", con);
                    cmd.Parameters.AddWithValue("@RoleID", roleID);
                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        hfRoleID.Value = dr["RoleID"].ToString();
                        txtRoleName.Text = dr["RoleName"].ToString();
                        ddlStatus.SelectedValue = dr["IsActive"].ToString();
                    }
                    con.Close();
                }

                ScriptManager.RegisterStartupScript(this, this.GetType(), "Pop", "openModal();", true);
            }
        }
    }
}
