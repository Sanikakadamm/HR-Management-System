using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;
using System.Configuration;
using System.Web.UI;

namespace HRMSProject
{
    public partial class Designation : System.Web.UI.Page
    {
        string conString = ConfigurationManager.ConnectionStrings["MyCon"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindGrid();
                PopulateDepartments(); // New method to fill dropdown
            }
        }

        private void PopulateDepartments()
        {
            using (SqlConnection con = new SqlConnection(conString))
            {
                // Assuming you have a standard SP to get all active departments
                SqlCommand cmd = new SqlCommand("SELECT DeptID, DeptName FROM Dept WHERE IsActive = 1", con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                ddlDept.DataSource = dt;
                ddlDept.DataTextField = "DeptName";
                ddlDept.DataValueField = "DeptID";
                ddlDept.DataBind();
                ddlDept.Items.Insert(0, new ListItem("-- Select Department --", "0"));
            }
        }

        private void BindGrid()
        {
            using (SqlConnection con = new SqlConnection(conString))
            {
                // Updated SP to JOIN with Dept table for the GridView
                SqlCommand cmd = new SqlCommand("sp_GetDesig", con);
                cmd.CommandType = CommandType.StoredProcedure;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvDesig.DataSource = dt;
                gvDesig.DataBind();
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            using (SqlConnection con = new SqlConnection(conString))
            {
                con.Open();
                SqlCommand cmd;

                if (string.IsNullOrEmpty(hfDesigID.Value))
                {
                    cmd = new SqlCommand("sp_InsertDesig", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DeptID", ddlDept.SelectedValue);
                    cmd.Parameters.AddWithValue("@DesigName", txtDesigName.Text);
                    cmd.Parameters.AddWithValue("@IsActive", Convert.ToBoolean(ddlStatus.SelectedValue));
                }
                else
                {
                    cmd = new SqlCommand("sp_UpdateDesig", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DesigID", hfDesigID.Value);
                    cmd.Parameters.AddWithValue("@DeptID", ddlDept.SelectedValue);
                    cmd.Parameters.AddWithValue("@DesigName", txtDesigName.Text);
                    cmd.Parameters.AddWithValue("@IsActive", Convert.ToBoolean(ddlStatus.SelectedValue));
                }

                cmd.ExecuteNonQuery();
                con.Close();

                hfDesigID.Value = "";
                txtDesigName.Text = "";
                ddlDept.SelectedIndex = 0;
                BindGrid();
            }
        }

        protected void gvDesig_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteRow")
            {
                int desigID = Convert.ToInt32(e.CommandArgument);
                using (SqlConnection con = new SqlConnection(conString))
                {
                    SqlCommand cmd = new SqlCommand("sp_DeleteDesig", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DesigID", desigID);
                    con.Open();
                    cmd.ExecuteNonQuery();
                    con.Close();
                    BindGrid();
                }
            }
            else if (e.CommandName == "EditRow")
            {
                int desigID = Convert.ToInt32(e.CommandArgument);
                using (SqlConnection con = new SqlConnection(conString))
                {
                    // Select DeptID as well for dropdown binding
                    SqlCommand cmd = new SqlCommand("SELECT DesigID, DeptID, DesigName, IsActive FROM Designation WHERE DesigID = @DesigID", con);
                    cmd.Parameters.AddWithValue("@DesigID", desigID);
                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        hfDesigID.Value = dr["DesigID"].ToString();
                        ddlDept.SelectedValue = dr["DeptID"].ToString();
                        txtDesigName.Text = dr["DesigName"].ToString();
                        ddlStatus.SelectedValue = dr["IsActive"].ToString();
                    }
                    con.Close();
                }

                ScriptManager.RegisterStartupScript(this, this.GetType(), "Pop", "openModal();", true);
            }
        }
    }
}
