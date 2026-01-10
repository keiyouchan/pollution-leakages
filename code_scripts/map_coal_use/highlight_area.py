# %%

# 绘制出虚假的key areas 用于安慰剂检验

import pandas as pd 
import numpy as np 
import os

from pyecharts.charts import Map
from pyecharts import options as opts

os.chdir("/Users/chandlerwong/Desktop/Pollution_project/data")

file = pd.read_stata("intermediate/false_key.dta")
data = list(file.to_records(index=False))

key_areas = [
    "北京市", "天津市", "石家庄市", "唐山市", "保定市", "廊坊市",
    "上海市", "南京市", "无锡市", "常州市", "苏州市", "南通市", "扬州市", "镇江市", "泰州市",
    "杭州市", "宁波市", "嘉兴市", "湖州市", "绍兴市",
    "广州市", "深圳市", "珠海市", "佛山市", "江门市", "肇庆市", "惠州市", "东莞市", "中山市",
    "沈阳市", "济南市", "青岛市", "淄博市", "潍坊市", "日照市",
    "武汉市", "长沙市", "重庆市", "成都市",
    "福州市", "三明市", "太原市", "西安市", "咸阳市", "兰州市", "银川市", "乌鲁木齐市"
]
key_data = [(area,2) for area in key_areas]
key_data

# %%
c = (
    Map()
    .add("示例指标", data + key_data, "china-cities", 
         map_value_calculation = "average",
         is_roam=False,
         symbol=None,
         label_opts=opts.LabelOpts(is_show=False),
         is_map_symbol_show=False
         )
    .set_global_opts(
        visualmap_opts=opts.VisualMapOpts(
            is_piecewise=True, 
            max_=2,
            is_show=True,
            ),
        title_opts=opts.TitleOpts(title="安慰剂检验：虚构处理组")
    )
)

c.render("false_treatment.html")
# %%

# %%
