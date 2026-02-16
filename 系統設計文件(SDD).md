---
# System prepended metadata

title: 系統設計文件(SDD)

---


# 系統設計文件(SDD)

- 專案名稱：海大拍賣系統
- 撰寫日期：2025/11/23
- 發展者：游承諺、王洪賢、張宸翊、蘇奕勳、蕭丞佑

---

## 版次變更記錄

| 版次 | 變更項目 | 變更日期 |
| --- | ------- | ------- |
| 0.1 | 初版 | 2025/12/25 |
| 0.2 | 流程圖+UI | 2026/02/11 |
| 0.3 | C4 Diagram更新 | 2026/02/17 |

---

## 目錄

1. [系統模型與架構 (System Model / System Architecture)](#section1)
2. [介面需求與設計 (Interface Requirement and Design)](#section2)
3. [流程設計 (Process Design)](#section3)
4. [使用者畫面設計 (User Interface Design)](#section4)
5. [資料設計 (Data Design)](#section5)
6. [類別圖設計 (Class Diagram)](#section6)
7. [實作方案 (Implementation Languages and Platforms)](#section7)
8. [設計議題 (Design Issue)](#section8)

---

## <span id="section1"> 1. 系統模型與架構 (System Model / System Architecture)</span>

### Container Diagram:
![Container-001](https://hackmd.io/_uploads/SyJw12g_be.png)
如上圖，本系統的核心由幾個重要的container組成:BFF(Backend For Frontend)、LIFF App、Core Backend、Database。BFF負責處理LIFF App (使用Node.js/Express)發送的API請求與向Core Backend(使用Python FastAPI)發送的業務邏輯請求，Core Backend 可能會讀寫資料庫(使用postgreSQL)或是呼叫外部系統如台語AI模型服務系統或是MCP Server執行 RAG 檢索、影音分析與語音互動等核心任務。

### Component Diagram:

![Component-001](https://hackmd.io/_uploads/SJkPk2eube.png)
上圖是BFF的Component圖，處理來自LIFF App 的請求以及 LINE端發送的 Webhook 事件，並且將核心業務的結果轉換成適當的格式和傳送訊息至Line Platform與更新Rich Menu。

![Component-002](https://hackmd.io/_uploads/rJIxxhl_Wx.png)
上圖是Core Backend的Component圖，負責接收BFF的請求，將請求傳送至醫療資源、語音轉文字、文件處理等服務並回傳結果至BFF，而使用者的偏好設定、醫療資源紀錄等會讀寫資料庫，語音轉文字會呼叫台語模型服務系統，文件處理與影片分析則呼叫MCP Server。

![Component-003](https://hackmd.io/_uploads/rkJDJ2gdbx.png)
上圖是LIFF App的Component圖，提供使用者在LINE介面中操作登入、個人資料、醫療服務與健康服務。

![Component-004](https://hackmd.io/_uploads/S11w1hxOZl.png)
上圖是MCP Server的Component圖，透過MCP API提供模組化工作流負責處理光學文字識別、影片、音訊處理等任務並由Workflow 管理器管理。

![Component-005](https://hackmd.io/_uploads/r1kvk2e_-l.png)

上圖是台語AI模型服務系統的Component圖，提供台語文字生成、台語文字轉音訊、台語語音轉文字功能，並透過模型管理器負責載入模型與版本、資源管理。




---

## <span id="section2">2. 介面需求與設計 (Interface Requirement and Design)</span>


---

## <span id="section3">3. 流程設計 (Process Design)</span>
### 主要操作流程
![操作流程](https://hackmd.io/_uploads/SJvTxZ9Dbg.png)

### 醫院資源定位流程

![GPS_Search_Activity.drawio](https://hackmd.io/_uploads/SyA1fZcvZx.png)

### 協助掛號流程

![Hospital_Register_Activity.drawio](https://hackmd.io/_uploads/HkelrWqD-g.png)

### 多媒體資訊處理流程
![Multimedia_Preprocess_Activity.drawio](https://hackmd.io/_uploads/r1N3MZ9P-x.png)

### 事實查核與RAG流程

![rag_medical_inference.drawio](https://hackmd.io/_uploads/HktdQb5wbl.png)

### 台語語音辨識與生成流程

![Taiwanese_Speech_Medical_Flow.drawio](https://hackmd.io/_uploads/ryTsQ-cDZx.png)

### MCP Server管理不同任務之流程
![CARE_Workflow.drawio](https://hackmd.io/_uploads/BJ07bW9wZx.png)



### 

---

## <span id="section4">4. 使用者畫面設計 (User Interface Design)</span>
### rich menu
#### 如下圖所示，CARE將主要服務透過rich menu呈現，讓使用者一目了然，降低高齡族群與之使用門檻
![RichMenu](https://hackmd.io/_uploads/r1UQTl5vZg.png)
### 手機版LIFF介面
#### LIFF介面提供健康資訊、語言設定、以及CARE系統主要服務
![手機LIFF](https://hackmd.io/_uploads/SyUmTlqw-g.png)
### 電腦版LIFF介面
#### 使用者輸入文字內容，CARE系統判斷內容並給予適當的協助，如下圖，系統依據使用者的狀況給出疾病原因與掛號科別
![電腦LIFF](https://hackmd.io/_uploads/SkUmTx5Dbg.png)
### 聊天互動頁面
#### 輸入“搜尋”後，CARE系統再徵得使用者同意後透過GPS查詢使用者所在地附近之醫療院所並回傳搜尋結果
![掛號-1](https://hackmd.io/_uploads/HkIQTl5P-x.png)
![掛號-2](https://hackmd.io/_uploads/rkI76x5PZl.png)



---

## <span id="section5">5. 資料設計 (Data Design)</span>
### 5.1 檔案結構
* 前端

* 後端


### 5.2 資料結構與Schema



---

## <span id="section6">6. 類別圖設計 (Class Diagram)</span>

---

## <span id="section7">7. 實作方案 (Implementation Languages and Platforms)</span>

- 平台：
- 前端技術與框架：
- 後端技術與框架： 
- 部署方式： 
---

## <span id="section8">8. 設計議題 (Design Issue)</span>
AI模型的記憶問題