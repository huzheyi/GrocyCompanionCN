FROM python:3.13.2-slim

WORKDIR /app

# 安装 Git（用于拉取代码）
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# 克隆仓库（构建时拉取代码）
RUN git clone https://github.com/huzheyi/GrocyCompanionCN.git /app

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 9288

CMD [ "sh", "-c", "cd /app && git pull && python app.py" ]