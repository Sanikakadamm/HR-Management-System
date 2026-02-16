using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;
using System.Configuration;
using System.Web.UI;

namespace HRMSProject.Modules
{
    public partial class Dept : System.Web.UI.Page
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
                SqlCommand cmd = new SqlCommand("sp_GetDept", con);
                cmd.CommandType = CommandType.StoredProcedure;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvDept.DataSource = dt;
                gvDept.DataBind();
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            using (SqlConnection con = new SqlConnection(conString))
            {
                con.Open();
                SqlCommand cmd;

                if (string.IsNullOrEmpty(hfDeptID.Value))
                {
                    cmd = new SqlCommand("sp_InsertDept", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DeptName", txtDeptName.Text);
                    cmd.Parameters.AddWithValue("@IsActive", Convert.ToBoolean(ddlStatus.SelectedValue));
                }
                else
                {
                    cmd = new SqlCommand("sp_UpdateDept", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DeptID", hfDeptID.Value);
                    cmd.Parameters.AddWithValue("@DeptName", txtDeptName.Text);
                    cmd.Parameters.AddWithValue("@IsActive", Convert.ToBoolean(ddlStatus.SelectedValue));
                }

                cmd.ExecuteNonQuery();
                con.Close();

                hfDeptID.Value = "";
                txtDeptName.Text = "";
                BindGrid();
            }
        }

        protected void gvDept_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteRow")
            {
                int deptID = Convert.ToInt32(e.CommandArgument);
                using (SqlConnection con = new SqlConnection(conString))
                {
                    SqlCommand cmd = new SqlCommand("sp_DeleteDept", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DeptID", deptID);
                    con.Open();
                    cmd.ExecuteNonQuery();
                    con.Close();
                    BindGrid();
                }
            }
            else if (e.CommandName == "EditRow")
            {
                int deptID = Convert.ToInt32(e.CommandArgument);
                using (SqlConnection con = new SqlConnection(conString))
                {
                    SqlCommand cmd = new SqlCommand("SELECT DeptID, DeptName, IsActive FROM Dept WHERE DeptID = @DeptID", con);
                    cmd.Parameters.AddWithValue("@DeptID", deptID);
                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        hfDeptID.Value = dr["DeptID"].ToString();
                        txtDeptName.Text = dr["DeptName"].ToString();
                        ddlStatus.SelectedValue = dr["IsActive"].ToString();
                    }
                    con.Close();
                }

                // Updated JS Registration for reliable modal popup
                ScriptManager.RegisterStartupScript(this, this.GetType(), "Pop", "openModal();", true);
            }
        }
    }
}
