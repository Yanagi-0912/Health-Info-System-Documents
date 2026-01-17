workspace "CARE" "CARE-Clinical Assistance & Resource Engine" {
    !identifiers hierarchical

    model {
        // ==================== People ====================
        user = person "使用者" "使用CARE系統尋求醫療及健康相關協助"
        
        // ==================== CARE Software System ====================
        care = softwareSystem "CARE" "CARE-Clinical Assistance & Resource Engine" {
            
            // ---------- LIFF Frontend ----------
            liff = container "LIFF App" "LINE Front-end Framework application" "React/Vue.js" {
                loginComponent = component "Login Component" "使用LINE帳號登入系統"
                userInfoComponent = component "User Profile Component" "管理使用者個人資料與偏好設定"
                hospitalServiceComponent = component "Hospital Service Component" "提供醫療相關服務功能，如:掛號輔助、醫院資訊查詢等"
                healthServiceComponent = component "Health Service Component" "提供健康相關服務功能，如:健康資訊查詢、健康提醒等"
            }
            
            // ---------- Backend for Frontend ----------
            bff = container "Backend for Frontend" "處理前端請求與LINE Webhook事件的轉換層(不處理商業邏輯)" "Node.js/Express" {
                // LINE Webhook 相關
                webhookController = component "Webhook Controller" "接收LINE Webhook事件並轉發給Core Backend"
                webhookEventAdapter = component "Webhook Event Adapter" "將LINE事件格式轉換為內部格式"
                
                // LINE Message 相關
                flexMessageAdapter = component "Flex Message Adapter" "將Core Backend回應轉換為LINE Flex Message格式"
                richMenuAdapter = component "Rich Menu Adapter" "將Rich Menu設定轉換為LINE API格式並同步"
                lineMessageClient = component "LINE Message Client" "封裝LINE Messaging API呼叫"
                
                // LIFF 相關
                liffSessionValidator = component "LIFF Session Validator" "驗證LIFF Access Token"
                liffRequestAdapter = component "LIFF Request Adapter" "將LIFF請求轉換為Core Backend API格式"
                liffResponseAdapter = component "LIFF Response Adapter" "將Core Backend回應轉換為LIFF前端格式"
                
                // 通用轉換層
                requestRouter = component "Request Router" "依 API path / event type 做靜態轉發，不包含任何業務判斷"
                responseFormatter = component "Response Formatter" "格式化回應給不同的客戶端"
            }
            
            // ---------- Core Backend ----------
            cb = container "Core Backend" "核心業務邏輯處理" "Python FastAPI" {
                // AI 相關服務
                aiResponseService = component "AI Response Service" "協調AI模型生成回覆(含對話管理、context處理)"
                factCheckingService = component "Fact Checking Service" "事實查核功能"
                videoAnalysisService = component "Video Analysis Service" "影片分析功能"
                
                // 語音處理
                ttsService = component "Text to Speech Service" "文字轉語音功能"
                asrService = component "Speech to Text Service" "語音轉文字功能"
                
                // 健康與醫療領域
                healthDomainService = component "Health Domain Service" "健康領域相關功能(健康資訊、提醒等)"
                hospitalResourceService = component "Hospital Resource Service" "醫院資源管理功能(掛號、查詢等)"
                
                // 使用者管理
                userManagementService = component "User Management Service" "使用者管理功能"
                userPreferenceService = component "User Preference Service" "使用者偏好設定管理"
                
                // 系統管理
                richMenuManagementService = component "Rich Menu Management Service" "Rich Menu內容與規則管理"
                
                // 對話管理
                conversationService = component "Conversation Service" "對話狀態管理與上下文處理"
                
                // 內容處理
                documentProcessingService = component "Document Processing Service" "處理PDF、圖片等文件"
                mediaProcessingService = component "Media Processing Service" "處理影片、音訊等媒體"
            }
            
            // ---------- Database ----------
            db = container "Database" "儲存使用者資料、對話紀錄、系統設定等" "MongoDB" {
                tags "Database"
            }
            
            // ---------- Cache ----------
            cache = container "Cache" "快取對話狀態、會話資料等" "Redis" {
                tags "Cache"
            }
        }

        // ==================== External Systems ====================
        
        linePlatform = softwareSystem "LINE Platform" "LINE官方平台，提供Messaging API與LIFF服務" {
            tags "External System"
        }

        taiwaneseAI = softwareSystem "台語 AI 模型服務系統" "提供台語相關 AI 能力之獨立模型服務系統" {
            modelApi = container "Taiwanese AI Model API" "基於 TAIDE Gemma 3 的台語大型語言模型與語音服務 API" "Python FastAPI" {
                llmService = component "Taiwanese LLM Service" "使用 TAIDE Gemma 3 產生台語文字回覆"
                ttsService = component "Taiwanese TTS Service" "將台語文字轉換為語音回覆（TTS）"
                asrService = component "Taiwanese ASR Service" "使用Breeze-ASR-25將台語語音轉換為文字（ASR）"
                modelManager = component "Model Manager" "負責模型載入、版本控管與資源管理"
            }
            tags "External System"
        }

        mcpServer = softwareSystem "MCP Server" "提供外部MCP Workflow服務" "n8n" {
            mcpApi = container "MCP API" "與MCP Workflow進行互動的API" {
                workflowManager = component "Workflow Manager" "管理MCP工作流程"
                ragWorkflow = component "RAG Workflow" "負責處理RAG相關工作流程"
                dataProcessingWorkflow = component "Data Processing Workflow" "負責處理資料處理相關工作流程"
                documentProcessingWorkflow = component "Document Processing Workflow" "負責處理文件處理相關工作流程"
                videoProcessingWorkflow = component "Video Processing Workflow" "負責處理影片處理相關工作流程"
                audioProcessingWorkflow = component "Audio Processing Workflow" "負責處理音訊處理相關工作流程"
                ocrWorkflow = component "OCR Workflow" "負責處理光學字元辨識相關工作流程"
            }
            tags "External System"
        }

        // ==================== Context Level Relationships ====================
        user -> linePlatform "透過LINE App與系統互動(傳送訊息、開啟LIFF)"
        user -> care.liff "使用醫療及健康相關功能"
        
        linePlatform -> care.bff "發送Webhook事件(訊息、追蹤、取消追蹤等)"
        care.bff -> linePlatform "發送訊息、更新Rich Menu等"
        care.liff -> care.bff "呼叫API獲取資料或執行操作"

        // ==================== Container Level Relationships ====================
        
        // LIFF to BFF
        care.liff -> care.bff "HTTPS/JSON" "呼叫API(使用者資料、醫療服務、健康資訊等)"
        
        // BFF to Core Backend
        care.bff -> care.cb "HTTPS/JSON" "轉發業務邏輯請求"
        
        // Core Backend to Database & Cache
        care.cb -> care.db "讀寫資料" "MongoDB Protocol"
        care.bff -> care.cache "僅儲存技術性會話資料（token / nonce / retry），不含業務狀態" "Redis Protocol"
        care.cb -> care.cache "快取查詢結果" "Redis Protocol"
        
        // Core Backend to External Systems
        care.cb -> taiwaneseAI.modelApi "調用台語AI模型" "HTTPS/JSON"
        care.cb -> mcpServer.mcpApi "調用MCP工作流程" "HTTPS/JSON"

        // ==================== Component Level Relationships ====================
        
        // --- LIFF Components to BFF ---
        care.liff.loginComponent -> care.bff.liffRequestAdapter "驗證LINE登入"
        care.liff.userInfoComponent -> care.bff.liffRequestAdapter "獲取/更新使用者資料"
        care.liff.hospitalServiceComponent -> care.bff.liffRequestAdapter "醫療服務請求"
        care.liff.healthServiceComponent -> care.bff.liffRequestAdapter "健康服務請求"
        
        // --- BFF LIFF Flow (只做轉換，不處理邏輯) ---
        care.bff.liffRequestAdapter -> care.bff.liffSessionValidator "驗證LIFF Access Token"
        care.bff.liffSessionValidator -> care.cache "檢查Token有效性"
        care.bff.liffRequestAdapter -> care.bff.requestRouter "路由到對應服務"
        
        // --- BFF Request Router to Core Backend ---
        care.bff.requestRouter -> care.cb.userManagementService "使用者相關請求"
        care.bff.requestRouter -> care.cb.userPreferenceService "使用者偏好請求"
        care.bff.requestRouter -> care.cb.hospitalResourceService "醫療服務請求"
        care.bff.requestRouter -> care.cb.healthDomainService "健康服務請求"
        care.bff.requestRouter -> care.cb.richMenuManagementService "Rich Menu管理請求"
        
        // --- BFF Response Flow ---
        care.cb.userManagementService -> care.bff.liffResponseAdapter "返回使用者資料"
        care.cb.userPreferenceService -> care.bff.liffResponseAdapter "返回偏好設定"
        care.cb.hospitalResourceService -> care.bff.liffResponseAdapter "返回醫療資訊"
        care.cb.healthDomainService -> care.bff.liffResponseAdapter "返回健康資訊"
        care.cb.richMenuManagementService -> care.bff.liffResponseAdapter "返回Rich Menu設定"
        care.bff.liffResponseAdapter -> care.bff.responseFormatter "格式化回應"
        
        // --- BFF Webhook Flow (只做事件轉換) ---
        linePlatform -> care.bff.webhookController "發送Webhook事件"
        care.bff.webhookController -> care.bff.webhookEventAdapter "轉換事件格式"
        care.bff.webhookEventAdapter -> care.bff.requestRouter "路由事件"
        
        // --- Webhook Router to Core Backend Services ---
        care.bff.requestRouter -> care.cb.conversationService "文字/圖片訊息" "處理一般對話"
        care.bff.requestRouter -> care.cb.videoAnalysisService "影片訊息"
        care.bff.requestRouter -> care.cb.documentProcessingService "文件訊息"
        care.bff.requestRouter -> care.cb.asrService "語音訊息"
        care.bff.requestRouter -> care.cb.userManagementService "追蹤/取消追蹤事件"
        
        // --- Core Backend Response to BFF (轉換為LINE格式) ---
        care.cb.conversationService -> care.bff.flexMessageAdapter "返回對話回應"
        care.cb.videoAnalysisService -> care.bff.flexMessageAdapter "返回影片分析結果"
        care.cb.documentProcessingService -> care.bff.flexMessageAdapter "返回文件處理結果"
        care.cb.asrService -> care.bff.flexMessageAdapter "返回語音轉文字結果"
        
        // --- BFF to LINE Platform ---
        care.bff.flexMessageAdapter -> care.bff.lineMessageClient "傳送Flex Message"
        care.bff.lineMessageClient -> linePlatform "推送訊息"
        
        // --- Rich Menu Sync Flow ---
        care.cb.richMenuManagementService -> care.bff.richMenuAdapter "Rich Menu設定變更通知"
        care.bff.richMenuAdapter -> care.bff.lineMessageClient "同步Rich Menu到LINE"
        care.bff.lineMessageClient -> linePlatform "更新Rich Menu"
        
        // --- Core Backend: Conversation Service Internal Flow ---
        care.cb.conversationService -> care.cache "讀寫對話狀態"
        care.cb.conversationService -> care.cb.userPreferenceService "獲取使用者語言偏好"
        care.cb.conversationService -> care.cb.aiResponseService "請求AI生成回覆"
        care.cb.conversationService -> care.cb.factCheckingService "需要事實查核時"
        
        // --- Core Backend: AI Response Service Flow ---
        care.cb.aiResponseService -> care.cb.userPreferenceService "獲取使用者AI偏好(風格、詳細度等)"
        care.cb.aiResponseService -> care.cb.ttsService "需要語音回覆時"
        care.cb.aiResponseService -> care.db "記錄對話歷史"
        
        // --- Core Backend: Fact Checking Flow ---
        care.cb.factCheckingService -> care.cb.aiResponseService "查核後修正回覆"
        
        // --- Core Backend: Video/Document Processing ---
        care.cb.videoAnalysisService -> care.cb.mediaProcessingService "處理影片"
        care.cb.documentProcessingService -> care.cb.mediaProcessingService "處理文件"
        
        // --- Core Backend: Rich Menu ---
        care.cb.richMenuManagementService -> care.db "存取Rich Menu設定"
        
        // --- Core Backend to Database ---
        care.cb.userManagementService -> care.db "CRUD使用者資料"
        care.cb.userPreferenceService -> care.db "CRUD使用者偏好"
        care.cb.healthDomainService -> care.db "讀取健康資訊、寫入健康紀錄"
        care.cb.hospitalResourceService -> care.db "讀取醫院資源資料"
        care.cb.conversationService -> care.db "記錄完整對話歷史"
        
        // --- Core Backend to Cache ---
        care.cb.conversationService -> care.cache "管理對話狀態(當前context、步驟等)"
        care.cb.aiResponseService -> care.cache "快取常用回覆模板"
        
        // --- Core Backend to External Systems ---
        care.cb.aiResponseService -> taiwaneseAI.modelApi.llmService "請求台語文字生成"
        care.cb.ttsService -> taiwaneseAI.modelApi.ttsService "請求台語TTS"
        care.cb.asrService -> taiwaneseAI.modelApi.asrService "請求台語ASR"
        
        care.cb.aiResponseService -> mcpServer.mcpApi.ragWorkflow "RAG查詢醫療知識"
        care.cb.documentProcessingService -> mcpServer.mcpApi.documentProcessingWorkflow "文件處理"
        care.cb.documentProcessingService -> mcpServer.mcpApi.ocrWorkflow "OCR識別"
        care.cb.mediaProcessingService -> mcpServer.mcpApi.videoProcessingWorkflow "影片處理"
        care.cb.mediaProcessingService -> mcpServer.mcpApi.audioProcessingWorkflow "音訊處理"
        care.cb.factCheckingService -> mcpServer.mcpApi.dataProcessingWorkflow "資料驗證"
        
        // --- Taiwanese AI Internal ---
        taiwaneseAI.modelApi.llmService -> taiwaneseAI.modelApi.modelManager "載入台語LLM"
        taiwaneseAI.modelApi.ttsService -> taiwaneseAI.modelApi.modelManager "載入TTS模型"
        taiwaneseAI.modelApi.asrService -> taiwaneseAI.modelApi.modelManager "載入ASR模型"
        
        // --- MCP Internal ---
        mcpServer.mcpApi.ragWorkflow -> mcpServer.mcpApi.workflowManager "執行工作流程"
        mcpServer.mcpApi.documentProcessingWorkflow -> mcpServer.mcpApi.workflowManager "執行工作流程"
        mcpServer.mcpApi.videoProcessingWorkflow -> mcpServer.mcpApi.workflowManager "執行工作流程"
        mcpServer.mcpApi.audioProcessingWorkflow -> mcpServer.mcpApi.workflowManager "執行工作流程"
        mcpServer.mcpApi.ocrWorkflow -> mcpServer.mcpApi.workflowManager "執行工作流程"
        mcpServer.mcpApi.dataProcessingWorkflow -> mcpServer.mcpApi.workflowManager "執行工作流程"
    }

    views {
        systemContext care "ContextDiagram" {
            include user
            include care
            include linePlatform
            include taiwaneseAI
            include mcpServer

            autoLayout lr
            title "[L1] CARE – System Context"
            description "CARE 系統與使用者及外部平台（LINE、AI、MCP）的互動關係"
        }

        container care "ContainerDiagram-Overview" {
            include user
            include care.liff
            include care.bff
            include care.cb
            include care.db
            include care.cache
            include linePlatform
            include taiwaneseAI
            include mcpServer

            autoLayout lr
            title "[L2] CARE – Container Overview"
            description "展示 CARE 的主要容器與責任分工（前端 / BFF / 核心後端）"
        }

        container care "ContainerDiagram-External" {
            include care.bff
            include care.cb
            include taiwaneseAI
            include mcpServer
            include linePlatform

            autoLayout lr
            title "[L2] CARE – External Integrations"
            description "CARE 與 LINE、台語 AI、MCP Workflow 的整合關係"
        }

        component care.bff "BFFComponentDiagram-CoreFlow" {
            include care.bff.webhookController
            include care.bff.webhookEventAdapter
            include care.bff.liffRequestAdapter
            include care.bff.liffSessionValidator
            include care.bff.requestRouter
            include care.bff.liffResponseAdapter
            include care.bff.flexMessageAdapter
            include care.bff.lineMessageClient

            autoLayout lr
            title "[L3] BFF – Message & Request Flow"
            description "BFF 僅負責請求轉換與轉送，不包含任何商業邏輯"
        }

        component care.cb "CoreBackend-ConversationAI" {
            include care.cb.conversationService
            include care.cb.aiResponseService
            include care.cb.factCheckingService
            include care.cb.userPreferenceService
            include care.cb.ttsService
            include care.cb.asrService
            include care.cache
            include care.db

            autoLayout lr
            title "[L3] Core Backend – Conversation & AI"
            description "核心後端中對話管理與 AI 回應的處理流程"
        }

        component care.cb "CoreBackend-HealthHospital" {
            include care.cb.healthDomainService
            include care.cb.hospitalResourceService
            include care.cb.userManagementService
            include care.cb.userPreferenceService
            include care.db

            autoLayout lr
            title "[L3] Core Backend – Health & Hospital Domain"
            description "健康與醫療資源相關的業務邏輯服務"
        }


        styles {
            /* =========================
               People
               ========================= */
            element "Person" {
                shape person
                background #2c3e50
                color #ffffff
                fontSize 38
            }
        
            /* =========================
               Software Systems
               ========================= */
            element "Software System" {
                shape roundedbox
                background #34495e
                color #ffffff
                fontSize 36
            }
        
            element "External System" {
                background #7f8c8d
                color #ffffff
                opacity 75
                fontSize 34
            }
        
            /* =========================
               Containers
               ========================= */
            element "Container" {
                shape roundedbox
                background #5dade2
                color #ffffff
                fontSize 34
            }
        
            element "Database" {
                shape cylinder
                background #48c9b0
                color #000000
                fontSize 32
            }
        
            element "Cache" {
                shape cylinder
                background #f5b041
                color #000000
                fontSize 32
            }
        
            /* =========================
               Components
               ========================= */
            element "Component" {
                shape roundedbox
                background #ecf0f1
                color #2c3e50
                stroke #95a5a6
                strokeWidth 2
                fontSize 32
            }
        
            /* =========================
               Emphasis / Key Roles
               ========================= */
        
            /* 核心商業邏輯（Core Backend 內部） */
            element "Core" {
                background #3498db
                color #ffffff
                fontSize 34
            }
        
            /* Adapter / Translator（BFF 專用） */
            element "Adapter" {
                background #d6eaf8
                color #1b4f72
                stroke #5dade2
                strokeWidth 2
                fontSize 32
            }
        
            /* =========================
               Relationships
               ========================= */
            relationship "Relationship" {
                color #ffffff
                thickness 2
                fontSize 30
            }
        
            relationship "Sync" {
                dashed false
                thickness 2
            }
        
            relationship "Async" {
                dashed true
                thickness 2
            }

        }

    }
}