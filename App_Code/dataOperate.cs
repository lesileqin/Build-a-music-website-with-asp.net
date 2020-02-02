using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Configuration;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Data.SqlClient;
/// <summary>
/// dataOperate 的摘要说明
/// </summary>
public class dataOperate
{
    public dataOperate()
    {
        //
        // TODO: 在此处添加构造函数逻辑
        //
    }
    /// <summary>
    /// 创建数据库连接
    /// </summary>
    /// <returns>返回SqlConnection对象</returns>
    public static SqlConnection createCon()
    {
        //创建SqlConnection对象
        SqlConnection con = new SqlConnection("server=DESKTOP-9FCSCD4;database=db_music;Trusted_Connection=SSPI;");
        return con;
    }
    /// <summary>
    /// 执行对数据库的添加、删除和插入操作
    /// </summary>
    /// <param name="sql">需要执行的SQL语句</param>
    /// <returns>返回一个布尔值，当执行成功返回True否则返回False</returns>
    public static bool execSql(string sql)
    {
        //创建数据库连接
        SqlConnection con = createCon();
        //打开数据库连接
        con.Open();
        //创建SqlCommand对象
        SqlCommand com = new SqlCommand(sql, con);
        //获取ExecuteNonQuery方法返回的值
        int i = com.ExecuteNonQuery();
        //关闭数据库连接
        con.Close();
        //判断返回的值是否大于1，大于1表示执行成功
        if (i > 0)
        {
            return true;
        }
        else
            return false;
    }
    /// <summary>
    /// 返回查询的指定列
    /// </summary>
    /// <param name="sql">需要查询的SQL语句</param>
    /// <returns>返回查询的列</returns>
    public static string getTier(string sql)
    {
        //创建数据库连接
        SqlConnection con = createCon();
        //打开数据库连接
        con.Open();
        //创建SqlCommand对象
        SqlCommand com = new SqlCommand(sql, con);
        //获取ExecuteReader方法返回的对象
        SqlDataReader sdr = com.ExecuteReader();
        //读取一条记录
        sdr.Read();
        //获取查询的指定列值
        string str = sdr[0].ToString();
        con.Close();
        sdr.Close();
        return str;

    }
    /// <summary>
    /// 查询数据并返回SqlDataReader对象
    /// </summary>
    /// <param name="sql">需要查询的SQL语句</param>
    /// <returns>返回SqlDataReader对象</returns>
    public static SqlDataReader getRow(string sql)
    {
        //创建数据库连接对象
        SqlConnection con = createCon();
        //打开数据库连接
        con.Open();
        //创建SqlCommdand对象
        SqlCommand com = new SqlCommand(sql, con);
        //获取ExecuteReader方法返回的SqlDataReader对象
        SqlDataReader sdr = com.ExecuteReader();
        return sdr;
    }

    /// <summary>
    /// 查询数据并返回DataSet对象
    /// </summary>
    /// <param name="sql">需要执行的SQL语句</param>
    /// <returns>返回DataSet对象</returns>
    public static DataSet getRows(string sql)
    {
        //创建数据库连接
        SqlConnection con = createCon();
        //打开数据库连接
        con.Open();
        //创建SqlDataAdapter对象
        SqlDataAdapter sda = new SqlDataAdapter(sql, con);
        //创建DataSet对象
        DataSet ds = new DataSet();
        //填充DataSet对象
        sda.Fill(ds);
        con.Close();
        return ds;


    }

}