# 加载所需的R包
library(tidyverse)
library(sf)
library(readxl)

# 中国地图坐标系
mycrs <- "+proj=aea +lat_0=0 +lon_0=105 +lat_1=25 +lat_2=47 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs" 

read_sf("/Users/chandlerwong/Desktop/使用\ R\ 语言绘制历年中国省市区县地图（小地图版本+长版）/citymapdata/minishp/chinacity2010mini/chinacity2010mini.shp") %>% 
  filter(!is.na(省代码)) -> citymap 

read_sf("/Users/chandlerwong/Desktop/使用\ R\ 语言绘制历年中国省市区县地图（小地图版本+长版）/citymapdata/minishp/chinacity2010mini/chinacity2010mini_line.shp") %>%
  st_set_crs(mycrs) %>%
  filter(!(class %in% c("秦岭-淮河线","指北针_线条","指北针_多边形","比例尺_线条","比例尺_多边形","胡焕庸线"))) %>%
  select(class) -> citylinemap

read_sf("/Users/chandlerwong/Desktop/使用\ R\ 语言绘制历年中国省市区县地图（小地图版本+长版）/provmapdata/minishp/chinaprov2010mini/chinaprov2010mini_line.shp") %>%
  st_set_crs(mycrs) %>%
  filter(!(class %in% c("秦岭-淮河线","指北针_线条","指北针_多边形","比例尺_线条","比例尺_多边形","胡焕庸线"))) %>%
  select(class) -> provlinemap

read_excel("/Users/chandlerwong/Desktop/子公司数据_用于r绘制地图.xlsx") -> firms
firms %>%
  count(市,year)  %>%
  filter(year == 2010) -> firmdf

citymap %>%
  left_join(firmdf) %>%
  mutate(n = if_else(is.na(n), 0 , n)) -> citymap2
citymap2 %>%
  DT::datatable()

# 绘图
library(ggspatial)
library(ggnewscale)

citymap %>%
  st_simplify(dTolerance = 2000) -> citymap_sim
citylinemap %>%
  st_simplify(dTolerance = 2000) -> citylinemap_sim
provlinemap %>%
  st_simplify(dTolerance = 2000) -> provlinemap_sim

ggplot()+
  geom_sf(data = citymap2, aes(fill = log(n + 1)),color = "grey",linewidth = 0.1) + 
  geom_sf(data = provlinemap_sim, linewidth = 0.3,
          show.legend = F) +
  geom_sf(data = citylinemap_sim, linewidth = 0.1,
          show.legend = F) +
  scale_fill_gradientn(
    colors = paletteer::paletteer_c("ggthemes::Blue", 10, direction = 1),
  ) +
  theme_minimal()


  scico::scale_fill_scico(palette = "ggthemes", 
                          trans = "log10",
                          name = "Number of firms",
                          direction = -1)
  
paletteer::paletteer_c()

paletteer::palettes_c_names %>%
  DT::datatable()
scico::scale_fill_scico()