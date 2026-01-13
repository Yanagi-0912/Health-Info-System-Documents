workspace "CARE" "CARE-Clinical Assistance & Resource Engine"{
    !identifiers hierarchical

    model {
        // People
        user = person "使用者" "使用CARE系統尋求醫療及健康相關協助"
        admin = person "管理員" "管理使用者回報問題、法律責任等"
        // Software System
        care = softwareSystem "CARE""CARE-Clinical Assistance & Resource Engine" {
            lma = container "LINE Message api"" "{
                FlexMessage = component "FlexMessage""使用LINE Flex Message回覆使用者訊息"
                RichMenu = component "Rich Menu""使用LINE Rich Menu提供選單功能"
                Webhook = component "Webhook""接收並處理來自LINE的事件"
                FactChecking = component "Fact Checking""事實查核功能"
                AIResponse = component "AI Response""使用AI模型生成回覆內容"
                TTS = component "Text to Speech""將文字轉換為語音回覆"
                VideoProcessing = component "Video Processing""處理並接收使用者上傳的影片"
                PdfProcessing = component "PDF Processing""處理並接收使用者上傳的PDF檔案"
                PictureProcessing = component "Picture Processing""處理並接收使用者上傳的圖片"
            }
            liff = container "LIFF""LINE Front-end Framework"{
                LogIn = component "LogIn with LINE""使用LINE帳號登入系統"
                UserInfo = component "User Information""管理使用者個人資料與偏好設定"
                HospitalSevice = component "Hospital Service""提供醫療相關服務功能，如:掛號輔助、醫院資訊查詢等"
                HealthService = component "Health Service""提供健康相關服務功能，如:健康資訊查詢、健康提醒等"
            }
            bff = container "Backend for Frontend""Node.js"{
                FlexMessageBuilder = component "Flex Message Builder""構建Flex Message"
                RichMenuController = component "Rich Menu Controller""管理Rich Menu"
                WebhookController = component "Webhook Controller""處理來自LINE的Webhook事件"
                EventParser = component "Event Parser""解析來自LINE的事件"
                ConversationStateManager = component "Conversation State Manager""管理使用者於對話中的狀態"
                FrontendRequestMapper = component "Frontend Request Mapper""映射前端請求"
                FrontendResponseAssembler = component "Frontend Response Assembler""組裝前端回應"
                LiffSessionManager = component "LIFF Session Manager""管理LIFF短期互動狀態(Cookie/Session)"
            }
            cb = container "Core Backend""Python FastApi"{
                AIResponseService = component "AI Response Service""使用AI模型生成回覆內容"
                FactCheckingService = component "Fact Checking Service""事實查核功能"
                VideoAnalysisService = component "Video Analysis Service""影片分析功能"
                TTSService = component "Text to Speech Service""文字轉語音功能"
                HealthDomainService = component "Health Domain Service""健康領域相關功能"
                HospitalResourceService = component "Hospital Resource Service""醫院資源管理功能"
                UserManagementService = component "User Management Service""使用者管理功能"
            }
            db = container "Database Schema""MongoDB" {
                tags "Database"
            }
        }

        // External Systems
        taiwanese = softwareSystem "台語 AI 模型服務系統" "提供台語相關 AI 能力之獨立模型服務系統" {
            modelApi = container "Taiwanese AI Model API""基於 TAIDE Gemma 3 的台語大型語言模型與語音服務 API" {
                llmService = component "Taiwanese LLM Service""使用 TAIDE Gemma 3 產生台語文字回覆"
                ttsService = component "Taiwanese Text-to-Speech Service" "將台語文字轉換為語音回覆（TTS）"
                asrService = component "Taiwanese Automatic Speech Recognition Service""使用Breeze-ASR-25將台語語音轉換為文字（ASR）"
                modelManager = component "Model Manager""負責模型載入、版本控管與資源管理"
    }
}


        mcp = softwareSystem "MCP Sever" "提供外部MCP Workflow服務(n8n)" {
            mcpApi = container "MCP Api" "與MCP Workflow進行互動的API"{
                WorkflowManager = component "Workflow Manager" "管理MCP工作流程"
                RAGWorkflow = component "RAG Workflow" "負責處理RAG相關工作流程"
                DataProcessingWorkflow = component "Data Processing Workflow" "負責處理資料處理相關工作流程"
                DocumentProcessingWorkflow = component "Document Processing Workflow" "負責處理文件處理相關工作流程"
                VideoProcessingWorkflow = component "Video Processing Workflow" "負責處理影片處理相關工作流程"
                AudioProcessingWorkflow = component "Audio Processing Workflow" "負責處理音訊處理相關工作流程"
                OCRWorkflow = component "OCR Workflow" "負責處理光學字元辨識相關工作流程"
            }
        }


        // Context Diagram
        user -> care.lma "向系統詢問問題、轉發影片"
        user -> care.liff "其他醫療及健康相關功能"
        admin -> care.liff "管理用戶回報問題、法律責任等"

        // Container Diagram
        care.lma -> care.bff "接收使用者LINE介面訊息"
        care.liff -> care.bff "Web前端應用程式"
        care.bff -> care.cb "轉化前端請求並調用核心後端API(不處理商業邏輯)"
        care.cb -> care.db "處理商業邏輯並讀寫資料庫中的資料"
        care.cb -> taiwanese.modelApi "調用台語AI模型服務系統API"
        care.cb -> mcp.mcpApi "調用MCP工作流程服務API"

        //Backend Component Diagram
        
        //Frontend Component Diagram
    }

    views {
        systemContext care "ContextDiagram" {
            include *
            autolayout lr
            title "CARE - Context Diagram"
        }

        container care "ContainerDiagram" {
            include *
            autolayout lr
            title "CARE - Container Diagram"
            
        }

        component care.liff "LIFFComponentDiagram" {
            include *
            autolayout lr
            title "CARE - LIFF元件圖 (LIFF Component Diagram)"
        }

        component care.lma "LMAComponentDiagram" {
            include *
            autolayout lr
            title "CARE - LINE Message API元件圖 (LMA Component Diagram)"
        }

        component care.bff "BFFComponentDiagram" {
            include *
            autolayout lr
            title "CARE - Backend for Frontend元件圖 (BFF Component Diagram)"
        }

        component care.cb "CoreBackendComponentDiagram" {
            include *
            autolayout lr
            title "CARE - Core Backend元件圖 (Core Backend Component Diagram)"
        }

        component taiwanese.modelApi "TaiwaneseAIModelAPIComponentDiagram" {
            include *
            autolayout lr
            title "台語 AI 模型服務系統元件圖 (Taiwanese AI Model API Component Diagram)"
        }

        component mcp.mcpApi "MCPAPIComponentDiagram" {
            include *
            autolayout lr
            title "MCP Sever元件圖 (MCP API Component Diagram)"
        }

        styles {
            element "Element" {
                color #0773af
                stroke #0773af
                strokeWidth 7
                shape roundedbox
            }
            element "Person" {
                shape person
            }
            element "Database" {
                shape cylinder
            }
            element "Boundary" {
                strokeWidth 5
            }
            relationship "Relationship" {
                thickness 4
            }
        }
    }
}