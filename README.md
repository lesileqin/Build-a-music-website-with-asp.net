# Build-a-music-website-with-asp.net
This project can listen to music online or download music, as well as the function of registering and collecting music. At present, there is only one song in the project, and interested friends can add music to the project by themselves.

----


# 一、效果预览

前往这里看效果：https://v.youku.com/v_show/id_XNDUzMDEwODc1Ng==.html?spm=a2h3j.8428770.3416059.1


# 二、预备知识

![1.png](https://i.loli.net/2020/02/02/EW7Tceaksugbwfn.png)

# 三、文件结构

![2.png](https://i.loli.net/2020/02/02/RIHaeyOcjkCJlbQ.png)

# 四、数据库设计

下面是数据库的三张表：

```sql
use db_music
go
create table tb_musicInfo(
	id int primary key,
	musicType int,
	speciaName varchar(500),
	musicName varchar(500),
	lyricPath varchar(500),
	singerName varchar(500),
	auditionSum int,
	downSum int,
	fileSize char(10),
	imgs varchar(500),
	country varchar(500),
	addtime datetime,
	zhuanji varchar(500),
	zjimg varchar(500),
	style varchar(200),
)
create table User(
	userName nvarchar(50),
	pwd nvarchar(50),
)
create table UserLove(
	musicId int,
	userName nvarchar(50)
)
```

# 五、部分代码展示

## 1、数据库增删改查

`dataOperate.cs`

```csharp
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
```

## 2、JSON数据解析

`f.cs`

```csharp
    public static string ToJson(this DataTable dt)
    {
        JavaScriptSerializer javaScriptSerializer = new JavaScriptSerializer();

        javaScriptSerializer.MaxJsonLength = Int32.MaxValue; //取得最大数值
        ArrayList arrayList = new ArrayList();
        foreach (DataRow dataRow in dt.Rows)
        {
            Dictionary<string, object> dictionary = new Dictionary<string, object>();  //实例化一个参数集合
            foreach (DataColumn dataColumn in dt.Columns)
            {
                dictionary.Add(dataColumn.ColumnName, dataRow[dataColumn.ColumnName].ToString());
            }
            arrayList.Add(dictionary); //ArrayList集合中添加键值
        }

        return "{root:" + javaScriptSerializer.Serialize(arrayList) + "}";  //返回一个json字符串
    }
```

## 3、ashx的使用

这个比较长，就不展示了，代码在`tools\Handler.ashx`中


