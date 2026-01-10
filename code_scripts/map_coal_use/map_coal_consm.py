
import pandas as pd 
import numpy as np 
import os

from pyecharts.charts import Map
from pyecharts import options as opts

os.chdir("/Users/chandlerwong/Desktop/Pollution_project/data")

province_map = {
    "北京": "北京市",
    "天津": "天津市",
    "上海": "上海市",
    "重庆": "重庆市",

    "河北": "河北省",
    "山西": "山西省",
    "辽宁": "辽宁省",
    "吉林": "吉林省",
    "黑龙江": "黑龙江省",

    "江苏": "江苏省",
    "浙江": "浙江省",
    "安徽": "安徽省",
    "福建": "福建省",
    "江西": "江西省",
    "山东": "山东省",

    "河南": "河南省",
    "湖北": "湖北省",
    "湖南": "湖南省",
    "广东": "广东省",
    "海南": "海南省",

    "四川": "四川省",
    "贵州": "贵州省",
    "云南": "云南省",
    "陕西": "陕西省",
    "甘肃": "甘肃省",
    "青海": "青海省",

    "内蒙古": "内蒙古自治区",
    "广西": "广西壮族自治区",
    "西藏": "西藏自治区",
    "宁夏": "宁夏回族自治区",
    "新疆": "新疆维吾尔自治区",

    "香港": "香港特别行政区",
    "澳门": "澳门特别行政区",
    "台湾": "台湾省",
    "全国总计":"全国地区"
}


key_areas = [
    "北京市", "天津市", "石家庄市", "唐山市", "保定市", "廊坊市",
    "上海市", "南京市", "无锡市", "常州市", "苏州市", "南通市", "扬州市", "镇江市", "泰州市",
    "杭州市", "宁波市", "嘉兴市", "湖州市", "绍兴市",
    "广州市", "深圳市", "珠海市", "佛山市", "江门市", "肇庆市", "惠州市", "东莞市", "中山市",
    "沈阳市", "济南市", "青岛市", "淄博市", "潍坊市", "日照市",
    "武汉市", "长沙市", "重庆市", "成都市",
    "福州市", "三明市", "太原市", "西安市", "咸阳市", "兰州市", "银川市", "乌鲁木齐市"
]

#%%
file = pd.read_excel("./raw/ene_by_region&indu.xlsx", sheet_name="分地区分品种能源消费量")
file = file[file["会计年度"].between(2012,2012)]
file["province"] = file["地区名称"].map(province_map)
file["ene_cons"] = file["能源合计(万吨标准煤)"]
file["province"]
data = list(file[["province","ene_cons"]].to_records(index=False))



c = (
    Map()
    .add("示例指标", data, "china", 
         map_value_calculation = "average",
         is_roam=False,
         symbol=None,
         label_opts=opts.LabelOpts(is_show=False),
         is_map_symbol_show=False
         )
    .set_global_opts(
        visualmap_opts=opts.VisualMapOpts(
            is_piecewise=False, 
            max_=30000,
            is_show=True,
            ),
        title_opts=opts.TitleOpts(title="2010~2012煤炭平均使用量")
    )
)

c.render("coal_use.html")
print("Image Successfully Renderred!")
