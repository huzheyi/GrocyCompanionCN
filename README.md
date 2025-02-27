# GrocyCompanionCN

GrocyCompanionCN is a http server working with grocy for prefetching goods information from the Internet. This project is a fork from https://github.com/osnsyc/GrocyCompanionCN, and a little bit modification is done to pass the authentication of GDS website.
Thanks to @osnsyc.

## 特性

- Grocy物品扫码出库;
- Grocy已有物品扫码入库,新物品自动获取商品详情并入库;(商品详情包括:条码,基础信息,图片,GPC类别,保质期判别等)

## 快速开始

### Grocy配置

Web界面中:
- `设置`-`管理API密钥`-`添加`
- `管理主数据`-`位置`- 根据自身情况添加
- `管理主数据`- `自定义字段`- `添加`- 表单信息:实体:products;名称GDSInfo;标题:GDSInfo;类型:单行文本,勾选"在表格中显示此列"
- 配置`数量单位`：`数量单位`-`添加`

### 创建 config.ini

```ini
# config.ini
[Grocy]
GROCY_URL = https://example.com
GROCY_PORT = 443
GROCY_API = YOUR_GROCY_API_KEY
# GROCY_DEFAULT_QUANTITY_UNIT_ID 在 shell内获取:
; curl -X 'GET' 'https://EXAMPLE.COM:PORT/api/objects/quantity_units' \  -H 'accept: application/json' \  -H 'GROCY-API-KEY:YOUR_GROCY_API_KEY' \  | echo -e "$(cat)"
GROCY_DEFAULT_QUANTITY_UNIT_ID = 1  # 默认的数量单位ID
GROCY_DEFAULT_BEST_BEFORE_DAYS = 365  # 默认的保质期天数

# 存储位置ID,与scanner.ino内的位置名称对应
# shell内获取,替换以下地址\端口\api_key:
; curl -X 'GET' 'https://EXAMPLE.COM:PORT/api/objects/locations' \
; -H 'accept: application/json' \
; -H 'GROCY-API-KEY:YOUR_GROCY_API_KEY' \
; | echo -e "$(cat)"
[GrocyLocation]
pantry = 1
temporary_storage = 2
fridge = 3
living_room = 4
bedroom = 5
bathroom = 6

[RapidAPI]
X_RapidAPI_Key = YOUR_RapidAPI_API_KEY

[GDS]
#在https://gds.org.cn注册用户，在请求头中获取Authorization中Bearer后面的内容
GDS_API_Bearer = Your_GDS_API_Bearer
```
其中，`GROCY_DEFAULT_QUANTITY_UNIT_ID`的获取方法:
```shell
curl -X 'GET' 'https://EXAMPLE.COM:PORT/api/objects/quantity_units' \
  -H 'accept: application/json' \
  -H 'GROCY-API-KEY:YOUR_GROCY_API_KEY' \
  | echo -e "$(cat)"
```

其中，`GrocyLocation`id的获取方法:
```shell
curl -X 'GET' 'https://EXAMPLE.COM:PORT/api/objects/locations' \
-H 'accept: application/json' \
-H 'GROCY-API-KEY:YOUR_GROCY_API_KEY' \
| echo -e "$(cat)"
```

### docker运行

docker run方式

```shell
docker pull ghcr.io/huzheyi/grocycompanioncn:latest
#docker pull huzheyi/grocycompanioncn:latest

docker run -itd \
  --name grocycc \
  --restart=always \
  -p 9288:9288 \
  -v ./config.ini:/config/config.ini \
  ghcr.io/huzheyi/grocycompanioncn:latest
```

或者docker-compose方式

```yml
# docker-compose.yml
version: "3"
services:
  spider:
    container_name: grocycc
    image: ghcr.io/huzheyi/grocycompanioncn:latest
    restart: always
    ports:
      - "9288:9288"
    volumes:
      - ./config.ini:/config/config.ini
      # - ./u2net.onnx:/root/.u2net/u2net.onnx
    networks:
      - grocy_cn_campanion

networks:
  grocy_cn_campanion:
```

`u2net.onnx`为rembg的模型,程序第一次运行时会自动下载,下载缓慢的也可[手动下载](https://github.com/danielgatis/rembg/releases/download/v0.0.0/u2net.onnx),放入`docker-compose.yml`同目录,并反注释以下一行
```yml
 - ./u2net.onnx:/root/.u2net/u2net.onnx
```

```shell
docker compose up -d
```

### 测试

打开`http://127.0.0.1:9288`,看到页面显示`GrocyCNCompanion Started!`,服务已成功运行.

GrocyCompanionCN api测试

```shell
curl -X POST -H "Content-Type: application/json" -d '{"client":"temporary_storage","aimid":"]E0","barcode":"8935024140147"}' http://127.0.0.1:9288/add
```

刷新Grocy,出现新物品

