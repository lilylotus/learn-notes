package com.example.demo.spider;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.http.HttpEntity;
import org.apache.http.StatusLine;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.ByteArrayBuffer;
import org.apache.http.util.EntityUtils;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.springframework.util.StringUtils;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class SpiderTest {

    private static final String USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36";

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyyMMddHHmm");
    private static final ObjectMapper MAPPER = new ObjectMapper();

    public static void main(String[] args) throws IOException {
//        parseJs();
//        String url = "https://static.ws.126.net/163/f2e/news/index2016_rmd/js/foot~91dfa147fc362.js";
//        pull2Local(news163, "163-home.html");

        final String homeFileName = "163-home.html";
        final String homeUrl = "https://news.163.com/";

        /*Document document = loadOnlineDocument(homeUrl);
        if (null == document) {
            System.out.println("-------------- 加载 Document 异常");
            return;
        }*/

//        parseJs(document);

        /*System.out.println("=================== top news");
        List<String> topNewsList = parseTopNews(document, false);
        System.out.println("=================== inner news");
        List<String> innerNewsList = parseNews(document, false);

        writeNews(topNewsList, innerNewsList);*/

        /*String json = "{\"navList\": [{\"name\": \"要闻\", \"type\": \"yaowen20200213\", \"totalPage\": 5 }, {\"name\": \"本地\", \"type\": \"bendi\", \"totalPage\": 3 }, {\"name\": \"国内\", \"type\": \"guonei\", \"totalPage\": 3 }, {\"name\": \"国际\", \"type\": \"guoji\", \"totalPage\": 2 }, {\"name\": \"独家\", \"type\": \"dujia\", \"totalPage\": 2 }, {\"name\": \"军事\", \"type\": \"war\", \"totalPage\": 2 }, {\"name\": \"财经\", \"type\": \"money\", \"totalPage\": 5 }, {\"name\": \"科技\", \"type\": \"tech\", \"totalPage\": 3 }, {\"name\": \"体育\", \"type\": \"sports\", \"totalPage\": 10 }, {\"name\": \"娱乐\", \"type\": \"ent\", \"totalPage\": 5 }, {\"name\": \"时尚\", \"type\": \"lady\", \"totalPage\": 3 }, {\"name\": \"汽车\", \"type\": \"auto\", \"totalPage\": 5 }, {\"name\": \"房产\", \"type\": \"house\", \"totalPage\": 3 }, {\"name\": \"航空\", \"type\": \"hangkong\", \"totalPage\": 2 }, {\"name\": \"健康\", \"type\": \"jiankang\", \"totalPage\": 3 } ], \"urlMap\": {\"getNewsData\": \"//news.163.com/special/cm_{{newstype}}{{pageno}}/?callback={{callbackName}}\", \"getYaoWenData\": \"//news.163.com/special/yaowen_channel_api/?callback={{callbackName}}&date=0120\", \"getBenDi\": \"{{newsurl}}{{pageno}}.js?callback={{callbackName}}\", \"getAdDetail\": \"//news.163.com/special/00014UDR/stream_ad.js?callback={{callbackName}}\", \"getNewsCityApi\": \"\"}, \"scrollLoad\": true, \"scrollLoadNum\": 2, \"fixedTabBtn\": true, \"newsdataNav\": \"newsdata_nav\", \"newsdataList\": \"newsdata_list\", \"loadMoreFoot\": \"load_more_foot\"}";
        Nav163 nav163 = parseJavList(json);
        System.out.println(nav163);
        loadNavListLink(json);*/


        /*String callUrl = "https://news.163.com/special/cm_jiankang_03/?callback=data_callback";
        String callJson = pull2String(callUrl);
        System.out.println(callJson);
        CallBackList callBackList = parseCallBackJson(callJson);
        System.out.println(callBackList.getItems().get(0));
        System.out.println(objectToString(callBackList.getItems().get(0)));*/

//        String newsUrl = "https://www.163.com/dy/article/HATPKOKU051492T3.html";
//        String newsUrl = "https://www.163.com/dy/article/HAV5UCG20512DU6N.html";
//        String newsUrl = "https://www.163.com/v/video/VAA13JF92.html";
        String newsUrl = "https://www.163.com/dy/article/HAPE4M470514R9OJ.html";

        NewsContentInfo info = parseNewsContent(newsUrl, true);
//        System.out.println(info);


        String imgUrl = "https://nimg.ws.126.net/?url=http%3A%2F%2Fdingyue.ws.126.net%2F2022%2F0628%2F3166ce26j00re5dsr001yc000ic00wkg.jpg&thumbnail=660x2147483647&quality=80&type=jpg";
        String videoUrl = "http://flv0.bn.netease.com/ebc38f492d1464bd94b642861cd31eb4942bce6078b18b1f647689e959c7c9e0849fdcb4358ef263d7e1b7265174dc3ec059b4dec9da38aa0fc5fa04a89212eee6a848dd332b71f8800fbd9cb502a1f5858d1f3fa5508fc6eaec554cecb444f5fd55218c49087e9e8449a628f66c6c8b50bd52f4c072e93d.mp4";
//        downloadOnlineFile(imgUrl, "C:\\Users\\sakura\\Desktop\\163", "test.jpg");
//        downloadOnlineFile(videoUrl, "C:\\Users\\sakura\\Desktop\\163", "test.mp4");
    }

    public static void downloadOnlineFile(String url, String path, String fileName) {
        try (final CloseableHttpClient client = HttpClients.createDefault()) {
            HttpGet get = new HttpGet(url);
            get.setHeader("User-Agent", USER_AGENT);

            try (CloseableHttpResponse response = client.execute(get)) {
                StatusLine statusLine = response.getStatusLine();
                System.out.println("code = " + statusLine.getStatusCode());

                HttpEntity entity = response.getEntity();
                InputStream inStream = entity.getContent();
                if (inStream != null) {
                    int capacity = (int) entity.getContentLength();
                    if (capacity < 0) {
                        capacity = 4096;
                    }
                    final ByteArrayBuffer buffer = new ByteArrayBuffer(capacity);
                    final byte[] tmp = new byte[1024];
                    int len;
                    try (BufferedInputStream inputStream = new BufferedInputStream(inStream)) {
                        while ((len = inputStream.read(tmp)) != -1) {
                            buffer.append(tmp, 0, len);
                        }
                    }
                    try (BufferedOutputStream out = new BufferedOutputStream(new FileOutputStream(new File(path, fileName)))) {
                        out.write(buffer.toByteArray());
                        out.flush();
                    }
                }
            }
        } catch (IOException exception) {
            exception.printStackTrace();
        }
    }

    public static NewsContentInfo parseNewsContent(String url, boolean print) {
        Document document = loadOnlineDocument(url);
        if (null == document) {
            return null;
        }

        NewsContentInfo info = new NewsContentInfo();
        Elements postTitle = document.select("h1.post_title");
        Elements postInfo = document.select(".post_info");
        Elements postBody = document.select("div.post_body > p");
        Elements postBodyImg = document.select("div.post_body > p img[src]");
        Elements postBodyVideo = document.select("div.post_body > p video[src]");
        Elements postBodyLink = document.select("div.post_body > p a[href]");

        if (postTitle.isEmpty()) {
            postTitle = document.select("div.title_wrap > h1");
            postInfo = document.select("div.title_intro");
            postBodyVideo = document.select("div.video_wrap video[src]");
        }


        String postTitleTxt = postTitle.text();
        String postInfoTxt = postInfo.text().replace("举报", "");

        info.setPostTitle(postTitleTxt);
        info.setPostInfo(postInfoTxt);

        if (print) {
            System.out.println(postTitleTxt);
            System.out.println(postInfoTxt);
        }

        for (Element p : postBody) {
            String txt = p.text();
            info.addBody(txt);
            if (print) {
                System.out.println(txt);
            }
        }

        for (Element img : postBodyImg) {
            String imgStr = "[" + img.attr("src") + "](" + img.attr("alt") + ")";
            info.addImg(imgStr);
            if (print) {
                System.out.println(imgStr);
            }
        }

        for (Element v : postBodyVideo) {
            String vStr = "[" + v.attr("src") + "](" + v.attr("alt") + ")";
            info.addVideo(vStr);
            if (print) {
                System.out.println(vStr);
            }
        }

        for (Element lk : postBodyLink) {
            String lStr = "[" + lk.attr("href") + "](" + lk.text() + ")";
            info.addLink(lStr);
            if (print) {
                System.out.println(lStr);
            }
        }

        return info;

    }

    public static String objectToString(Object obj) {
        try {
            return MAPPER.writeValueAsString(obj);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }
        return "";
    }

    public static void loadNavListLink(String json) {
        Nav163 nav = parseJavList(json);

        NavUrlMap urlMap = nav.getUrlMap();
        String getNewsData = urlMap.getGetNewsData();
        System.out.println("getNewsData = " + getNewsData);

        List<NavItem> navList = nav.getNavList();
        for (NavItem navItem : navList) {
            System.out.println("========== start " + navItem.getName());
            String callBackUrl = getNewsData.replace("{{newstype}}", navItem.getType()).replace("{{callbackName}}", "data_callback");
            for (int i = 1; i <= navItem.getTotalPage(); i++) {
                System.out.println("https:" + callBackUrl.replace("{{pageno}}", i == 1 ? "" : ("_0" + i)));
            }
            System.out.println("========== end " + navItem.getName());
        }

    }

    public static void writeNews(List<String> topNews, List<String> innerNews) {
        final String newsFileName = "news-163-" + FORMATTER.format(LocalDateTime.now()) + ".md";
        try (BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(
                new FileOutputStream("C:\\Users\\sakura\\Desktop\\163\\" + newsFileName), StandardCharsets.UTF_8))) {

            writer.write("## top news");
            writer.newLine();

            for (String line : topNews) {
                writer.write(line);
                writer.newLine();
            }

            writer.write("## inner news");
            writer.newLine();

            for (String n : innerNews) {
                writer.write(n);
                writer.newLine();
            }

            writer.flush();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static Document loadDocument(String fileName) {
        try {
            return Jsoup.parse(new File("C:\\Users\\sakura\\Desktop\\163\\" + fileName), "UTF-8");
        } catch (IOException exception) {
            exception.printStackTrace();
        }
        return null;
    }

    public static Document loadOnlineDocument(String url) {
        try {
            return Jsoup.connect(url).get();
        } catch (IOException exception) {
            exception.printStackTrace();
        }
        return null;
    }

    public static List<String> parseNews(final Document document, boolean print) {
        Elements newsList = document.select("ul.newsdata_list");
        Elements links = newsList.select("a[href]");
        List<String> resultList = new ArrayList<>(300);
        for (Element link : links) {
            String linkContent = "[" + link.text() + "](" + link.attr("href") + ")";
            resultList.add(linkContent);
            if (print) {
                System.out.println(linkContent);
            }
        }
        return resultList;
    }

    public static List<String> parseTopNews(Document document, boolean print) {
        // js_top_news
        System.out.println("title = " + document.title());

        List<String> resultList = new ArrayList<>(50);
        Elements topNews = document.select("#js_top_news > div.news_default_news");
        Elements topNewsLinks = topNews.select("a[href]");

        for (Element link : topNewsLinks) {
            String newsContent = "[" + link.text() + "](" + link.attr("href") + ")";
            resultList.add(newsContent);
            if (print) {
                System.out.println(newsContent);
            }
        }

        return resultList;
    }

    public static void parseJs(Document document) throws IOException {

        Elements jsList = document.select("script[src*=/163/f2e/news]");
        String jsUrl = null;
        for (Element js : jsList) {
            jsUrl = js.attr("src");
            System.out.println(jsUrl);
        }
        if (null == jsUrl) {
            System.out.println("JS Url 没有解析到");
            return;
        }

        String path = "C:\\Users\\sakura\\Desktop\\163\\163.js";
        pull2Local(jsUrl, "163.js");
        String js = Files.readAllLines(new File(path).toPath()).get(0);

        Pattern compile = Pattern.compile("(\\{navList:.*\"load_more_foot\"})");
        Matcher matcher = compile.matcher(js);

        if (matcher.find()) {
            String json = matcher.group(0);
            System.out.println(json);
        }

        /*String json = "{\"navList\": [{\"name\": \"要闻\", \"type\": \"yaowen20200213\", \"totalPage\": 5 }, {\"name\": \"本地\", \"type\": \"bendi\", \"totalPage\": 3 }, {\"name\": \"国内\", \"type\": \"guonei\", \"totalPage\": 3 }, {\"name\": \"国际\", \"type\": \"guoji\", \"totalPage\": 2 }, {\"name\": \"独家\", \"type\": \"dujia\", \"totalPage\": 2 }, {\"name\": \"军事\", \"type\": \"war\", \"totalPage\": 2 }, {\"name\": \"财经\", \"type\": \"money\", \"totalPage\": 5 }, {\"name\": \"科技\", \"type\": \"tech\", \"totalPage\": 3 }, {\"name\": \"体育\", \"type\": \"sports\", \"totalPage\": 10 }, {\"name\": \"娱乐\", \"type\": \"ent\", \"totalPage\": 5 }, {\"name\": \"时尚\", \"type\": \"lady\", \"totalPage\": 3 }, {\"name\": \"汽车\", \"type\": \"auto\", \"totalPage\": 5 }, {\"name\": \"房产\", \"type\": \"house\", \"totalPage\": 3 }, {\"name\": \"航空\", \"type\": \"hangkong\", \"totalPage\": 2 }, {\"name\": \"健康\", \"type\": \"jiankang\", \"totalPage\": 3 } ], \"urlMap\": {\"getNewsData\": \"//news.163.com/special/cm_{{newstype}}{{pageno}}/?callback={{callbackName}}\", \"getYaoWenData\": \"//news.163.com/special/yaowen_channel_api/?callback={{callbackName}}&date=0120\", \"getBenDi\": \"{{newsurl}}{{pageno}}.js?callback={{callbackName}}\", \"getAdDetail\": \"//news.163.com/special/00014UDR/stream_ad.js?callback={{callbackName}}\", \"getNewsCityApi\": \"\"}, \"scrollLoad\": true, \"scrollLoadNum\": 2, \"fixedTabBtn\": true, \"newsdataNav\": \"newsdata_nav\", \"newsdataList\": \"newsdata_list\", \"loadMoreFoot\": \"load_more_foot\"}";
        ObjectMapper mapper = new ObjectMapper();
        Map map = mapper.readValue(json, Map.class);
        System.out.println(map);*/

        /*try (final BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(path), StandardCharsets.UTF_8))) {

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException exception) {
            exception.printStackTrace();
        }*/
    }

    public static Nav163 parseJavList(String json) {
        // {"navList": [{"name": "要闻", "type": "yaowen20200213", "totalPage": 5 }, {"name": "本地", "type": "bendi", "totalPage": 3 }, {"name": "国内", "type": "guonei", "totalPage": 3 }, {"name": "国际", "type": "guoji", "totalPage": 2 }, {"name": "独家", "type": "dujia", "totalPage": 2 }, {"name": "军事", "type": "war", "totalPage": 2 }, {"name": "财经", "type": "money", "totalPage": 5 }, {"name": "科技", "type": "tech", "totalPage": 3 }, {"name": "体育", "type": "sports", "totalPage": 10 }, {"name": "娱乐", "type": "ent", "totalPage": 5 }, {"name": "时尚", "type": "lady", "totalPage": 3 }, {"name": "汽车", "type": "auto", "totalPage": 5 }, {"name": "房产", "type": "house", "totalPage": 3 }, {"name": "航空", "type": "hangkong", "totalPage": 2 }, {"name": "健康", "type": "jiankang", "totalPage": 3 } ], "urlMap": {"getNewsData": "//news.163.com/special/cm_{{newstype}}{{pageno}}/?callback={{callbackName}}", "getYaoWenData": "//news.163.com/special/yaowen_channel_api/?callback={{callbackName}}&date=0120", "getBenDi": "{{newsurl}}{{pageno}}.js?callback={{callbackName}}", "getAdDetail": "//news.163.com/special/00014UDR/stream_ad.js?callback={{callbackName}}", "getNewsCityApi": ""}, "scrollLoad": true, "scrollLoadNum": 2, "fixedTabBtn": true, "newsdataNav": "newsdata_nav", "newsdataList": "newsdata_list", "loadMoreFoot": "load_more_foot"}
        ObjectMapper mapper = new ObjectMapper();
        Nav163 result = null;
        try {
            result = mapper.readValue(json, Nav163.class);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }
        System.out.println(result);
        return result;
    }

    public static String pull2String(String url) {
        String responseString = "";

        try (final CloseableHttpClient client = HttpClients.createDefault()) {
            HttpGet get = new HttpGet(url);
            get.setHeader("User-Agent", USER_AGENT);

            try (CloseableHttpResponse response = client.execute(get)) {
                StatusLine statusLine = response.getStatusLine();
                System.out.println("code = " + statusLine.getStatusCode());
                responseString = EntityUtils.toString(response.getEntity(), StandardCharsets.UTF_8);
            }
        } catch (IOException exception) {
            exception.printStackTrace();
        }

        responseString = responseString.replace("data_callback(", "{\"items\":");
        responseString = responseString.replace("])", "]}");

        return responseString;
    }


    public static CallBackList parseCallBackJson(String json) {
        ObjectMapper mapper = new ObjectMapper();
        try {
            return mapper.readValue(json, CallBackList.class);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static void pull2Local(final String url, final String fileName) {
//        String url = "https://static.ws.126.net/163/f2e/news/index2016_rmd/js/foot~91dfa147fc362.js";
        String responseString = "";

        try (final CloseableHttpClient client = HttpClients.createDefault()) {
            HttpGet get = new HttpGet(url);
            get.setHeader("User-Agent", USER_AGENT);

            try (CloseableHttpResponse response = client.execute(get)) {
                StatusLine statusLine = response.getStatusLine();
                System.out.println("code = " + statusLine.getStatusCode());
                responseString = EntityUtils.toString(response.getEntity(), StandardCharsets.UTF_8);
            }
        } catch (IOException exception) {
            exception.printStackTrace();
        }

        try (BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(
                new FileOutputStream("C:\\Users\\sakura\\Desktop\\163\\" + fileName), StandardCharsets.UTF_8))) {
            writer.write(responseString);
            writer.flush();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException exception) {
            exception.printStackTrace();
        }
    }

    static class Nav163 {
        private Boolean scrollLoad;
        private Boolean fixedTabBtn;
        private Integer scrollLoadNum;
        private String newsdataNav;
        private String newsdataList;
        private String loadMoreFoot;

        private NavUrlMap urlMap;

        private List<NavItem> navList;

        public Boolean getScrollLoad() {
            return scrollLoad;
        }

        public void setScrollLoad(Boolean scrollLoad) {
            this.scrollLoad = scrollLoad;
        }

        public Boolean getFixedTabBtn() {
            return fixedTabBtn;
        }

        public void setFixedTabBtn(Boolean fixedTabBtn) {
            this.fixedTabBtn = fixedTabBtn;
        }

        public Integer getScrollLoadNum() {
            return scrollLoadNum;
        }

        public void setScrollLoadNum(Integer scrollLoadNum) {
            this.scrollLoadNum = scrollLoadNum;
        }

        public String getNewsdataNav() {
            return newsdataNav;
        }

        public void setNewsdataNav(String newsdataNav) {
            this.newsdataNav = newsdataNav;
        }

        public String getNewsdataList() {
            return newsdataList;
        }

        public void setNewsdataList(String newsdataList) {
            this.newsdataList = newsdataList;
        }

        public String getLoadMoreFoot() {
            return loadMoreFoot;
        }

        public void setLoadMoreFoot(String loadMoreFoot) {
            this.loadMoreFoot = loadMoreFoot;
        }

        public NavUrlMap getUrlMap() {
            return urlMap;
        }

        public void setUrlMap(NavUrlMap urlMap) {
            this.urlMap = urlMap;
        }

        public List<NavItem> getNavList() {
            return navList;
        }

        public void setNavList(List<NavItem> navList) {
            this.navList = navList;
        }

        @Override
        public String toString() {
            return "Nav163{" +
                    "scrollLoad=" + scrollLoad +
                    ", fixedTabBtn=" + fixedTabBtn +
                    ", scrollLoadNum=" + scrollLoadNum +
                    ", newsdataNav='" + newsdataNav + '\'' +
                    ", newsdataList='" + newsdataList + '\'' +
                    ", loadMoreFoot='" + loadMoreFoot + '\'' +
                    ", urlMap=" + urlMap +
                    ", navList=" + navList +
                    '}';
        }
    }

    static class NavUrlMap {
        private String getNewsData;
        private String getYaoWenData;
        private String getBenDi;
        private String getAdDetail;
        private String getNewsCityApi;

        public String getGetNewsData() {
            return getNewsData;
        }

        public void setGetNewsData(String getNewsData) {
            this.getNewsData = getNewsData;
        }

        public String getGetYaoWenData() {
            return getYaoWenData;
        }

        public void setGetYaoWenData(String getYaoWenData) {
            this.getYaoWenData = getYaoWenData;
        }

        public String getGetBenDi() {
            return getBenDi;
        }

        public void setGetBenDi(String getBenDi) {
            this.getBenDi = getBenDi;
        }

        public String getGetAdDetail() {
            return getAdDetail;
        }

        public void setGetAdDetail(String getAdDetail) {
            this.getAdDetail = getAdDetail;
        }

        public String getGetNewsCityApi() {
            return getNewsCityApi;
        }

        public void setGetNewsCityApi(String getNewsCityApi) {
            this.getNewsCityApi = getNewsCityApi;
        }

        @Override
        public String toString() {
            return "NavUrlMap{" +
                    "getNewsData='" + getNewsData + '\'' +
                    ", getYaoWenData='" + getYaoWenData + '\'' +
                    ", getBenDi='" + getBenDi + '\'' +
                    ", getAdDetail='" + getAdDetail + '\'' +
                    ", getNewsCityApi='" + getNewsCityApi + '\'' +
                    '}';
        }
    }

    static class NavItem {
        private String name;
        private String type;
        private Integer totalPage;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getType() {
            return type;
        }

        public void setType(String type) {
            this.type = type;
        }

        public Integer getTotalPage() {
            return totalPage;
        }

        public void setTotalPage(Integer totalPage) {
            this.totalPage = totalPage;
        }

        @Override
        public String toString() {
            return "NavItem{" +
                    "name='" + name + '\'' +
                    ", type='" + type + '\'' +
                    ", totalPage=" + totalPage +
                    '}';
        }
    }

    static class CallBackList {
        private List<CallBackItem> items;

        public List<CallBackItem> getItems() {
            return items;
        }

        public void setItems(List<CallBackItem> items) {
            this.items = items;
        }
    }

    public static class CallBackItem {
        private String title;
        private String digest;
        private String docurl;
        private String commenturl;
        private Integer tienum;
        private String tlastid;
        private String tlink;
        private String label;
        private List<CallKeyWords> keywords;
        private String time;
        private String newstype;
        private List<String> pics3;
        private String channelname;
        private String source;
        private String point;
        private String imgurl;
        private String add1;
        private String add2;
        private String add3;

        @Override
        public String toString() {
            return "CallBackItem{" +
                    "title='" + title + '\'' +
                    ", digest='" + digest + '\'' +
                    ", docurl='" + docurl + '\'' +
                    ", commenturl='" + commenturl + '\'' +
                    ", tienum=" + tienum +
                    ", tlastid='" + tlastid + '\'' +
                    ", tlink='" + tlink + '\'' +
                    ", label='" + label + '\'' +
                    ", keywords=" + keywords +
                    ", time='" + time + '\'' +
                    ", newstype='" + newstype + '\'' +
                    ", pics3=" + pics3 +
                    ", channelname='" + channelname + '\'' +
                    ", source='" + source + '\'' +
                    ", point='" + point + '\'' +
                    ", imgurl='" + imgurl + '\'' +
                    ", add1='" + add1 + '\'' +
                    ", add2='" + add2 + '\'' +
                    ", add3='" + add3 + '\'' +
                    '}';
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public String getDigest() {
            return digest;
        }

        public void setDigest(String digest) {
            this.digest = digest;
        }

        public String getDocurl() {
            return docurl;
        }

        public void setDocurl(String docurl) {
            this.docurl = docurl;
        }

        public String getCommenturl() {
            return commenturl;
        }

        public void setCommenturl(String commenturl) {
            this.commenturl = commenturl;
        }

        public Integer getTienum() {
            return tienum;
        }

        public void setTienum(Integer tienum) {
            this.tienum = tienum;
        }

        public String getTlastid() {
            return tlastid;
        }

        public void setTlastid(String tlastid) {
            this.tlastid = tlastid;
        }

        public String getTlink() {
            return tlink;
        }

        public void setTlink(String tlink) {
            this.tlink = tlink;
        }

        public String getLabel() {
            return label;
        }

        public void setLabel(String label) {
            this.label = label;
        }

        public List<CallKeyWords> getKeywords() {
            return keywords;
        }

        public void setKeywords(List<CallKeyWords> keywords) {
            this.keywords = keywords;
        }

        public String getTime() {
            return time;
        }

        public void setTime(String time) {
            this.time = time;
        }

        public String getNewstype() {
            return newstype;
        }

        public void setNewstype(String newstype) {
            this.newstype = newstype;
        }

        public List<String> getPics3() {
            return pics3;
        }

        public void setPics3(List<String> pics3) {
            this.pics3 = pics3;
        }

        public String getChannelname() {
            return channelname;
        }

        public void setChannelname(String channelname) {
            this.channelname = channelname;
        }

        public String getSource() {
            return source;
        }

        public void setSource(String source) {
            this.source = source;
        }

        public String getPoint() {
            return point;
        }

        public void setPoint(String point) {
            this.point = point;
        }

        public String getImgurl() {
            return imgurl;
        }

        public void setImgurl(String imgurl) {
            this.imgurl = imgurl;
        }

        public String getAdd1() {
            return add1;
        }

        public void setAdd1(String add1) {
            this.add1 = add1;
        }

        public String getAdd2() {
            return add2;
        }

        public void setAdd2(String add2) {
            this.add2 = add2;
        }

        public String getAdd3() {
            return add3;
        }

        public void setAdd3(String add3) {
            this.add3 = add3;
        }
    }

    static class CallKeyWords {
        private String akey_link;
        private String keyname;

        public String getAkey_link() {
            return akey_link;
        }

        public void setAkey_link(String akey_link) {
            this.akey_link = akey_link;
        }

        public String getKeyname() {
            return keyname;
        }

        public void setKeyname(String keyname) {
            this.keyname = keyname;
        }
    }

    static class NewsContentInfo {

        private String postTitle;
        private String postInfo;
        private List<String> postBody = new ArrayList<>(20);
        private List<String> images = new ArrayList<>(10);
        private List<String> videos = new ArrayList<>(10);
        private List<String> links = new ArrayList<>(10);

        @Override
        public String toString() {
            return "NewsContentInfo{" +
                    "postTitle='" + postTitle + '\'' +
                    ", postInfo='" + postInfo + '\'' +
                    ", postBody=" + postBody +
                    ", images=" + images +
                    ", videos=" + videos +
                    ", links=" + links +
                    '}';
        }

        public void addBody(String body) {
            if (StringUtils.hasText(body)) {
                postBody.add(body);
            }
        }

        public void addImg(String img) {
            if (StringUtils.hasText(img)) {
                images.add(img);
            }
        }

        public void addVideo(String video) {
            if (StringUtils.hasText(video)) {
                videos.add(video);
            }
        }

        public void addLink(String link) {
            if (StringUtils.hasText(link)) {
                links.add(link);
            }
        }

        public List<String> getLinks() {
            return links;
        }

        public void setLinks(List<String> links) {
            this.links = links;
        }

        public String getPostTitle() {
            return postTitle;
        }

        public void setPostTitle(String postTitle) {
            this.postTitle = postTitle;
        }

        public String getPostInfo() {
            return postInfo;
        }

        public void setPostInfo(String postInfo) {
            this.postInfo = postInfo;
        }

        public List<String> getPostBody() {
            return postBody;
        }

        public void setPostBody(List<String> postBody) {
            this.postBody = postBody;
        }

        public List<String> getImages() {
            return images;
        }

        public void setImages(List<String> images) {
            this.images = images;
        }

        public List<String> getVideos() {
            return videos;
        }

        public void setVideos(List<String> videos) {
            this.videos = videos;
        }
    }

    //        Elements postTitle = document.select("h1.post_title");
    //        Elements postInfo = document.select(".post_info");
    //        Elements postBody = document.select("div.post_body > p");
    //        Elements postBodyImg = document.select("div.post_body > p img[src]");
    //        Elements postBodyVideo = document.select("div.post_body > p video[src]");

}
