<%@ WebHandler Language="C#" Class="Handler" %>

using System;
using System.Web;
using System.Data;
using System.IO;
using ICSharpCode.SharpZipLib.Checksums;
using ICSharpCode.SharpZipLib.Zip;
using ICSharpCode.SharpZipLib.GZip;

public class Handler : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{

    public void ProcessRequest(HttpContext context)
    {
        //HttpContext.Current.Session["userName"] = "admin";
        //前台传递过来的标识
        string t = HttpContext.Current.Request["t"];
        switch (t)
        {
            case "reg":
                //调用注册方法
                Reg(context);
                break;
            case "CheckLogin":
                //检查是否登录
                CheckLogin(context);
                break;
            case "login":
                //登录方法
                login(context);
                break;
            case "GetLove":
                //猜你喜欢
                GetLove(context);
                break;
            case "lisem":
                //听歌
                lisem(context);
                break;
            case "getlisen":
                //获取歌曲
                getlisen(context);
                break;
            case "Gettuijian":
                //获取推荐
                Gettuijian(context);
                break;
            case "GetRank":
                //查询排行
                GetRank(context);
                break;
            case "GetZj":
                //查询专辑
                GetZj(context);
                break;
            case "SetArtist":
                //设置艺人
                SetArtist(context);
                break;
            case "GetSingmusic":
                //根据人获取歌曲
                GetSingmusic(context);
                break;
            case "GetStyle":
                //根据风格查询歌曲
                GetStyle(context);
                break;
            case "SetLove":
                //设置收藏
                SetLove(context);
                break;
            case "GetMyLove":
                //获取我的收藏
                GetMyLove(context);
                break;
            case "SetFind":
                //设置查询
                SetFind(context);
                break;
            case "GetFind":
                //查询歌曲
                GetFind(context);
                break;
            case "OutHtml":
                //退出方法
                outHtml(context);
                break;
            case "Down":
                //下载文件
                Down(context);
                break;
            case "upmusic":
                InsertMusic(context);
                break;
        }

    }
    /// <summary>
    /// 压缩文件
    /// </summary>
    /// <param name="fileName">要压缩的所有文件（完全路径)</param>
    /// <param name="name">压缩后文件路径</param>
    /// <param name="Level">压缩级别</param>
    public void ZipFileMain(string[] filenames, string name, int Level)
    {
        ZipOutputStream s = new ZipOutputStream(File.Create(name));
        Crc32 crc = new Crc32();
        //压缩级别
        s.SetLevel(Level); // 0 - store only to 9 - means best compression
        try
        {
            foreach (string file in filenames)
            {
                //打开压缩文件
                FileStream fs = File.OpenRead(file);
                byte[] buffer = new byte[fs.Length];
                fs.Read(buffer, 0, buffer.Length);
                //建立压缩实体
                ZipEntry entry = new ZipEntry(System.IO.Path.GetFileName(file));
                //时间
                entry.DateTime = DateTime.Now;
                //空间大小
                entry.Size = fs.Length;
                //关闭文件流
                fs.Close();
                //重置
                crc.Reset();
                crc.Update(buffer);
                entry.Crc = crc.Value;
                s.PutNextEntry(entry);
                s.Write(buffer, 0, buffer.Length);
            }
        }
        catch
        {
            throw;
        }
        finally
        {
            s.Finish();
            s.Close();
        }

    }
    /// <summary>
    /// 下载文件
    /// </summary>
    /// <param name="context"></param>
    public void Down(HttpContext context)
    {
        //获取文件地址
        string file = HttpContext.Current.Request["file"];
        //转换成服务器绝对路径
        string url = context.Server.MapPath("../" + file);
        //设置文件名称
        string time = Guid.NewGuid().ToString();
        //组合成文件相对路径
        string md = "../musicFile/" + time + ".zip";
        //压缩文件
        ZipFileMain(new string[] { url }, context.Server.MapPath(md), 0);
        context.Response.Write("{\"status\":\"" + time + ".zip\"}");
    }
    /// <summary>
    /// 退出
    /// </summary>
    /// <param name="context"></param>
    public void outHtml(HttpContext context)
    {
        //服务器标识设置为空
        HttpContext.Current.Session["userName"] = null;
        context.Response.Write("{\"status\":\"0\"}");
    }
    /// <summary>
    /// 查询歌曲
    /// </summary>
    /// <param name="context"></param>
    public void GetFind(HttpContext context)
    {

        //第几页
        int pageInt = int.Parse(HttpContext.Current.Request["pageInt"]);
        //一页多少条数据
        int pageCount = int.Parse(HttpContext.Current.Request["pageCount"]);
        //查询的东西
        string findStr = HttpContext.Current.Session["findStr"].ToString();
        //开始行数
        int start = pageInt * pageCount - (pageCount - 1);
        //结束行数
        int end = pageInt * pageCount;
        //设置sql语句
        string sql = "select * from (select *,ROW_NUMBER()OVER(order by addtime) AS RowNum from( select * from tb_musicInfo where musicName like '%" + findStr + "%') as a) as b where RowNum>=" + start + " and RowNum<=" + end + "";
        //获取后台数据
        DataTable dt = dataOperate.getRows(sql).Tables[0];
        if (dt.Rows.Count > 0)
        {
            //格式化后台数据
            string json = f.ToJson(dt);
            json = json.Replace("\"", "\\\"");
            context.Response.Write("{\"status\":\"" + json + "\"}");
        }
        else
        {
            context.Response.Write("{\"status\":\"-1\"}");
        }
    }
    /// <summary>
    /// 设置查询
    /// </summary>
    /// <param name="context"></param>
    public void SetFind(HttpContext context)
    {
        //设置查询内容
        HttpContext.Current.Session["findStr"] = HttpContext.Current.Request["findStr"];
        context.Response.Write("{\"status\":\"0\"}");
    }
    /// <summary>
    /// 获取我收藏的
    /// </summary>
    /// <param name="context"></param>
    public void GetMyLove(HttpContext context)
    {
        //第几页
        int pageInt = int.Parse(HttpContext.Current.Request["pageInt"]);
        //一页多少条数据
        int pageCount = int.Parse(HttpContext.Current.Request["pageCount"]);
        //设置登录名
        string userName = HttpContext.Current.Session["userName"].ToString();
        //开始行数
        int start = pageInt * pageCount - (pageCount - 1);
        //结束行数
        int end = pageInt * pageCount;
        //设置sql语句
        string sql = "select * from (select *,ROW_NUMBER()OVER(order by addtime) AS RowNum from( select tb_musicInfo.* from tb_musicInfo,UserLove where tb_musicInfo.id=UserLove.musicId and UserLove.userName ='" + userName + "' ) as a) as b where RowNum>=" + start + " and RowNum<=" + end + "";
        //获取后台数据
        DataTable dt = dataOperate.getRows(sql).Tables[0];
        if (dt.Rows.Count > 0)
        {
            //格式化后台传递过来的数据
            string json = f.ToJson(dt);
            json = json.Replace("\"", "\\\"");
            context.Response.Write("{\"status\":\"" + json + "\"}");
        }
        else
        {
            context.Response.Write("{\"status\":\"-1\"}");
        }
    }
    /// <summary>
    /// 设置收藏
    /// </summary>
    /// <param name="context"></param>
    public void SetLove(HttpContext context)
    {
        //检验此人登录没有
        if (HttpContext.Current.Session["userName"] == null)
        {
            //如果没有登录返回-1
            context.Response.Write("{\"status\":\"-1\"}");
            return;
        }
        //音乐id
        string musicId = HttpContext.Current.Request["musicId"];
        //用户名
        string userName = HttpContext.Current.Session["userName"].ToString();
        //组合sql语句
        string sql = "insert into UserLove(musicId,userName) values('" + musicId + "','" + userName + "')";
        //执行sql语句
        dataOperate.execSql(sql);
        context.Response.Write("{\"status\":\"0\"}");
    }
    /// <summary>
    /// 根据风格查询歌曲
    /// </summary>
    /// <param name="context"></param>
    public void GetStyle(HttpContext context)
    {
        //排行类型
        string phType = HttpContext.Current.Request["phType"];
        //第几页
        int pageInt = int.Parse(HttpContext.Current.Request["pageInt"]);
        //一页多少条数据
        int pageCount = int.Parse(HttpContext.Current.Request["pageCount"]);
        //开始行数
        int start = pageInt * pageCount - (pageCount - 1);
        //结束行数
        int end = pageInt * pageCount;
        //组合成sql语句
        string sql = "select * from (select *,ROW_NUMBER()OVER(order by addtime) AS RowNum from( select * from tb_musicInfo where style like '%" + phType + "%' ) as a) as b where RowNum>=" + start + " and RowNum<=" + end + "";
        //查询数据库中的内容
        DataTable dt = dataOperate.getRows(sql).Tables[0];
        if (dt.Rows.Count > 0)
        {
            //格式化内容
            string json = f.ToJson(dt);
            json = json.Replace("\"", "\\\"");
            context.Response.Write("{\"status\":\"" + json + "\"}");
        }
        else
        {
            context.Response.Write("{\"status\":\"-1\"}");
        }
    }
    /// <summary>
    /// 根据人获取歌曲
    /// </summary>
    /// <param name="context"></param>
    public void GetSingmusic(HttpContext context)
    {
        //第几页
        int pageInt = int.Parse(HttpContext.Current.Request["pageInt"]);
        //一页多少条数据
        int pageCount = int.Parse(HttpContext.Current.Request["pageCount"]);
        string Artist = HttpContext.Current.Session["Artist"].ToString();
        //开始行数
        int start = pageInt * pageCount - (pageCount - 1);
        //结束行数
        int end = pageInt * pageCount;
        //组合成sql语句
        string sql = "select * from (select *,ROW_NUMBER()OVER(order by addtime) AS RowNum from( select * from tb_musicInfo where singerName like '%" + Artist + "%' or zhuanji like '%" + Artist + "%') as a) as b where RowNum>=" + start + " and RowNum<=" + end + "";
        //返回后台数据
        DataTable dt = dataOperate.getRows(sql).Tables[0];
        if (dt.Rows.Count > 0)
        {
            //格式化查找的数据
            string json = f.ToJson(dt);
            json = json.Replace("\"", "\\\"");
            context.Response.Write("{\"status\":\"" + json + "\"}");
        }
        else
        {
            context.Response.Write("{\"status\":\"-1\"}");
        }
    }
    /// <summary>
    /// 设置艺人
    /// </summary>
    /// <param name="context"></param>
    public void SetArtist(HttpContext context)
    {
        //设置艺人
        HttpContext.Current.Session["Artist"] = HttpContext.Current.Request["Artist"];
        context.Response.Write("{\"status\":\"0\"}");
    }
    /// <summary>
    /// 查询专辑
    /// </summary>
    /// <param name="context"></param>
    public void GetZj(HttpContext context)
    {
        //排行类型
        string phType = HttpContext.Current.Request["phType"];
        //国家
        string country = HttpContext.Current.Request["country"];
        //第几页
        int pageInt = int.Parse(HttpContext.Current.Request["pageInt"]);
        //一页多少条数据
        int pageCount = int.Parse(HttpContext.Current.Request["pageCount"]);
        //设置标识
        string orderyb = "singerName";
        if (phType == "1")
        {
            orderyb = "zjimg";
        }
        //开始行数
        int start = pageInt * pageCount - (pageCount - 1);
        //结束行
        int end = pageInt * pageCount;
        //组合成sql语句
        string sql = "select * from (select *,ROW_NUMBER()OVER(order by " + orderyb + ") AS RowNum from( select distinct singerName,zjimg,musicName,zhuanji  from tb_musicInfo where country like '%" + country + "%' ) as a) as b where RowNum>=" + start + " and RowNum<=" + end + "";
        //查询后台数据
        DataTable dt = dataOperate.getRows(sql).Tables[0];
        if (dt.Rows.Count > 0)
        {
            //格式化数据
            string json = f.ToJson(dt);
            json = json.Replace("\"", "\\\"");
            context.Response.Write("{\"status\":\"" + json + "\"}");
        }
        else
        {
            context.Response.Write("{\"status\":\"-1\"}");
        }
    }
    /// <summary>
    /// 查询排行榜
    /// </summary>
    /// <param name="context"></param>
    public void GetRank(HttpContext context)
    {
        //排行类型
        string phType = HttpContext.Current.Request["phType"];
        //国家
        string country = HttpContext.Current.Request["country"];
        //第几页
        int pageInt = int.Parse(HttpContext.Current.Request["pageInt"]);
        //一页多少条数据
        int pageCount = int.Parse(HttpContext.Current.Request["pageCount"]);
        string orderyb = "musicName";
        if (phType == "1")
        {
            orderyb = "addtime";
        }
        if (phType == "2")
        {
            orderyb = "musicType";
        }
        //开始行数
        int start = pageInt * pageCount - (pageCount - 1);
        //结束行数
        int end = pageInt * pageCount;
        //组合成sql语句
        string sql = "select * from (select *,ROW_NUMBER()OVER(order by " + orderyb + ") AS RowNum from( select * from tb_musicInfo where country like '%" + country + "%' ) as a) as b where RowNum>=" + start + " and RowNum<=" + end + "";
        //查询后台数据
        DataTable dt = dataOperate.getRows(sql).Tables[0];
        if (dt.Rows.Count > 0)
        {
            //格式化代码
            string json = f.ToJson(dt);
            json = json.Replace("\"", "\\\"");
            context.Response.Write("{\"status\":\"" + json + "\"}");
        }
        else
        {
            context.Response.Write("{\"status\":\"-1\"}");
        }
    }

    /// <summary>
    /// 获取歌曲
    /// </summary>
    /// <param name="context"></param>
    public void getlisen(HttpContext context)
    {
        //是否有准备播放的mp3
        if (HttpContext.Current.Session["mp3"] != null)
        {
            //如果有要播放的mp3就返回
            context.Response.Write("{\"status\":\"" + HttpContext.Current.Session["mp3"].ToString() + "\"}");
            return;
        }
        //如果没有
        context.Response.Write("{\"status\":\"-1\"}");
    }
    /// <summary>
    /// 听歌
    /// </summary>
    /// <param name="context"></param>
    public void lisem(HttpContext context)
    {
        //获取要听的mp3
        string mp3 = HttpContext.Current.Request["mp3"];
        //设置mp3
        HttpContext.Current.Session["mp3"] = mp3;
        context.Response.Write("{\"status\":\"0\"}");
    }
    /// <summary>
    /// 注册
    /// </summary>
    /// <param name="context"></param>
    public void Reg(HttpContext context)
    {
        //获取用户名
        string userName = HttpContext.Current.Request["userName"];
        //设置用户名
        HttpContext.Current.Session["userName"] = userName;
        //设置密码
        string pwd = HttpContext.Current.Request["pwd"];
        //设置sql语句
        string sqlCheck = "select userName from [User] where userName='" + userName + "'";
        //查询语句在数据库中
        int checkdata = dataOperate.getRows(sqlCheck).Tables[0].Rows.Count;
        if (checkdata != 0)
        {
            context.Response.Write("{\"status\":\"-1\"}");
            return;
        }
        //插入语句
        string sql = "insert into [User](userName,pwd) values('" + userName + "','" + pwd + "')";
        //执行语句
        dataOperate.execSql(sql);
        context.Response.Write("{\"status\":\"0\"}");
    }
    /// <summary>
    /// 是否登录
    /// </summary>
    /// <param name="context"></param>
    public void CheckLogin(HttpContext context)
    {
        //是否已经登录
        if (HttpContext.Current.Session["userName"] == null)
        {
            context.Response.Write("{\"status\":\"-1\"}");
            return;
        }
        context.Response.Write("{\"status\":\"" + HttpContext.Current.Session["userName"].ToString() + "\"}");
    }
    /// <summary>
    /// 用户登录
    /// </summary>
    /// <param name="context"></param>
    public void login(HttpContext context)
    {
        //获取用户名
        string userName = HttpContext.Current.Request["userName"];
        //获取密码
        string pwd = HttpContext.Current.Request["pwd"];
        ////设置sql语句
        string sql = "select userName from [User] where userName='" + userName + "' and pwd='" + pwd + "'";
        //查询语句
        int checkdata = dataOperate.getRows(sql).Tables[0].Rows.Count;
        if (checkdata == 0)
        {

            context.Response.Write("{\"status\":\"-1\"}");
            return;
        }
        HttpContext.Current.Session["userName"] = userName;
        context.Response.Write("{\"status\":\"0\"}");
    }
    /// <summary>
    /// 猜你喜欢
    /// </summary>
    /// <param name="context"></param>
    public void GetLove(HttpContext context)
    {
        //查询语句
        string sql = "select top 4 *,NEWID() as random from tb_musicInfo order by random";
        //查到数据
        DataTable dt = dataOperate.getRows(sql).Tables[0];
        if (dt != null)
        {
            //格式化数据
            string json = f.ToJson(dt);
            json = json.Replace("\"", "\\\"");
            context.Response.Write("{\"status\":\"" + json + "\"}");
        }
    }
    /// <summary>
    /// 获取推荐
    /// </summary>
    /// <param name="context"></param>
    public void Gettuijian(HttpContext context)
    {
        //设置查询语句
        string sql = "select top 10 *,NEWID() as random from tb_musicInfo order by random";
        //到数据库中查询
        DataTable dt = dataOperate.getRows(sql).Tables[0];
        if (dt != null)
        {
            ////格式化数据
            string json = f.ToJson(dt);
            json = json.Replace("\"", "\\\"");
            context.Response.Write("{\"status\":\"" + json + "\"}");
        }
    }
    public void InsertMusic(HttpContext context)
    {
        string zj = HttpContext.Current.Request["zj"];
        string zjtp = HttpContext.Current.Request["zjtp"];
        string gs = HttpContext.Current.Request["gs"];
        string fg = HttpContext.Current.Request["fg"];
        string mc = HttpContext.Current.Request["mc"];
        string fname = HttpContext.Current.Request["fname"];
        string gj = HttpContext.Current.Request["gj"];
        string tp = HttpContext.Current.Request["tp"];
        string sql = "insert into tb_musicInfo(musicType,specialName,musicName,musicPath,lyricPath,singerName,auditionSum,downSum,fileSize,imgs,country,addtime,zhuanji,zjimg,style) values(1,'','" + mc + "','" + fname + "','py.lrc','" + gs + "','1','1','1','" + tp + "','" + gj + "','" + DateTime.Now.ToString() + "','" + zj + "','" + zjtp + "','" + fg + "')";
        dataOperate.execSql(sql);
        context.Response.Write("{\"status\":\"0\"}");
    }
    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}