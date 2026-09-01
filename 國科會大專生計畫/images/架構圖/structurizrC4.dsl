workspace "CARE" "CARE - Clinical Assistance & Resource Engine" {
    !identifiers hierarchical
    
    model {
        // ==================== Actors ====================
        user = person "使用者" "透過 LINE 尋求醫療、健康協助"
        
        // ==================== Core System ====================
        care = softwareSystem "CARE" "Clinical Assistance & Resource Engine" {
            // --- Presentation Layer ---
            liff = container "LIFF App" "LINE 前端應用" "React / Vue.js" {
                login = component "登入元件" "使用 LINE 帳號登入系統"
                profile = component "個人資料元件" "管理使用者個人資料與偏好設定"
                hospitalSvc = component "醫療服務元件" "提供醫療相關服務，如:掛號輔助、醫院資訊查詢等"
                healthSvc = component "健康服務元件" "提供健康相關服務，如:健康資訊查詢、健康提醒等"
            }
            
            // --- API Gateway / BFF ---
            bff = container "BFF" "Backend For Frontend + LINE Webhook 轉接層 (不處理商業邏輯)" "Node.js / Express" {
                // --- Webhook 相關 ---
                webhookCtrl = component "Webhook 控制器" "接收 LINE Webhook 事件並轉發"
                webhookAdapter = component "Webhook 事件轉換器" "將 LINE 事件轉換為內部格式" {
                    tags "Adapter"
                }
                flexAdapter = component "Flex Message 轉換器" "將 Core 回應轉換為 LINE Flex 格式" {
                    tags "Adapter"
                }
                richMenuAdapter = component "Rich Menu 同步器" "將 Rich Menu 設定轉換並同步到 LINE" {
                    tags "Adapter"
                }
                lineClient = component "LINE Messaging Client" "封裝 LINE API 呼叫"

                // --- LIFF 相關 ---
                liffAdapter = component "LIFF 請求轉換器" "將 LIFF 請求轉換為 Core API 格式" {
                    tags "Adapter"
                }
                liffRespAdapter = component "LIFF 回應轉換器" "將 Core 回應轉換為 LIFF 前端格式" {
                    tags "Adapter"
                }

                // --- 通用 ---
                router = component "請求路由器" "依 path / event type 靜態轉發 (無業務判斷)"
                respFormatter = component "回應格式化器" "格式化回應給不同客戶端"
            }
            
            // --- Business Logic Core ---
            core = container "Core Backend" "核心業務邏輯處理" "Python FastAPI" {
                // --- Conversation & AI ---
                conv = component "對話管理服務" "對話狀態管理與上下文處理"
                aiResponse = component "AI 回應協調服務" "協調 AI 模型生成回覆 (含對話管理、context 處理)" {
                    tags "Core" "AI"
                }
                factCheck = component "事實查核服務" "事實查核功能" {
                    tags "Core" "AI"
                }
                videoAnalysis = component "影片分析服務" "影片分析功能" {
                    tags "Core"
                }
                
                // --- Speech Processing ---
                tts = component "文字轉語音服務" "文字轉語音功能" {
                    tags "Core" "AI"
                }
                asr = component "語音轉文字服務" "語音轉文字功能" {
                    tags "Core" "AI"
                }
                
                // --- Domain Services ---
                healthDomain = component "健康領域服務" "健康相關功能 (健康資訊、提醒等)" {
                    tags "Core"
                }
                hospitalSvc = component "醫院資源服務" "醫院資源管理功能 (掛號、查詢等)" {
                    tags "Core"
                }
                
                // --- User Management ---
                userMgmt = component "使用者管理服務" "使用者管理功能" {
                    tags "Core"
                }
                preference = component "偏好設定服務" "使用者偏好設定管理" {
                    tags "Core"
                }
                
                // --- Content Processing ---
                docProcess = component "文件處理服務" "處理 PDF、圖片等文件" {
                    tags "Core"
                }
                mediaProcess = component "媒體處理服務" "處理影片、音訊等媒體" {
                    tags "Core"
                }
                
                // --- System Management ---
                richMenuMgmt = component "Rich Menu 管理服務" "Rich Menu 內容與規則管理" {
                    tags "Core"
                }
            }
            
            // --- Storage ---
            db = container "Database" "儲存使用者資料、對話紀錄、系統設定等" "PostgreSQL" {
                tags "Database"
            }
        }
        
        // ==================== External Systems ====================
        line = softwareSystem "LINE Platform" "提供 Messaging API 與 LIFF 服務" {
            tags "External"
        }
        
        twAI = softwareSystem "台語 AI 模型服務系統" "提供台語相關 AI 能力" {
            twApi = container "台語模型 API" "基於 TAIDE Gemma 3 的台語 LLM 與語音服務" "Python FastAPI" {
                llm = component "台語 LLM 服務" "產生台語文字回覆" {
                    tags "AI"
                }
                tts = component "台語 TTS 服務" "文字轉台語語音" {
                    tags "AI"
                }
                asr = component "台語 ASR 服務" "台語語音轉文字 (Breeze-ASR-25)" {
                    tags "AI"
                }
                mgr = component "模型管理器" "模型載入、版本控制與資源管理"
            }
            tags "External"
        }
        
        mcp = softwareSystem "MCP Server" "提供外部 MCP Workflow 服務" {
            mcpApi = container "MCP API" "與 MCP Workflow 互動" {
                wfMgr = component "Workflow 管理器" "管理 MCP 工作流程"
                rag = component "RAG Workflow" "處理 RAG 相關工作流程" {
                    tags "Async"
                }
                dataWf = component "資料處理 Workflow" "處理資料驗證等" {
                    tags "Async"
                }
                docWf = component "文件處理 Workflow" "處理文件相關" {
                    tags "Async"
                }
                videoWf = component "影片處理 Workflow" "處理影片相關" {
                    tags "Async"
                }
                audioWf = component "音訊處理 Workflow" "處理音訊相關" {
                    tags "Async"
                }
                ocrWf = component "OCR Workflow" "光學字元辨識" {
                    tags "Async"
                }
            }
            tags "External"
        }
        
        // ==================== Context Level Relationships ====================
        user -> line "透過 LINE App 互動 (傳送訊息、開啟 LIFF)"
        user -> care.liff "使用醫療及健康相關功能"
        line -> care.bff "發送 Webhook 事件 (訊息、追蹤等)"
        care.bff -> line "發送訊息、更新 Rich Menu 等"
        
        // ==================== Container Level Relationships ====================
        care.liff -> care.bff "呼叫 API (使用者資料、醫療服務等)" "HTTPS/JSON" {
            tags "Sync"
        }
        care.bff -> care.core "轉發業務邏輯請求" "HTTPS/JSON" {
            tags "Sync"
        }
        care.core -> care.db "讀寫資料" "PostgreSQL Protocol" {
            tags "Sync"
        }
        care.core -> twAI.twApi "調用台語 AI 模型" "HTTPS/JSON" {
            tags "Sync"
        }
        care.core -> mcp.mcpApi "調用 MCP 工作流程" "HTTPS/JSON" {
            tags "Async"
        }
        
        // ==================== Component Level Relationships ====================
        // --- LIFF to BFF ---
        care.liff.login -> care.bff.liffAdapter "驗證 LINE 登入" {
            tags "Sync"
        }
        care.liff.profile -> care.bff.liffAdapter "獲取/更新使用者資料" {
            tags "Sync"
        }
        care.liff.hospitalSvc -> care.bff.liffAdapter "醫療服務請求" {
            tags "Sync"
        }
        care.liff.healthSvc -> care.bff.liffAdapter "健康服務請求" {
            tags "Sync"
        }
        care.bff.liffAdapter -> care.bff.router "路由請求" {
            tags "Sync"
        }
        
        // --- BFF Router to Core ---
        care.bff.router -> care.core.userMgmt "使用者相關" {
            tags "Sync"
        }
        care.bff.router -> care.core.preference "偏好設定" {
            tags "Sync"
        }
        care.bff.router -> care.core.hospitalSvc "醫療服務" {
            tags "Sync"
        }
        care.bff.router -> care.core.healthDomain "健康服務" {
            tags "Sync"
        }
        care.bff.router -> care.core.richMenuMgmt "Rich Menu 管理" {
            tags "Sync"
        }
        
        // --- Core Response to BFF (LIFF Flow) ---
        care.core.userMgmt -> care.bff.liffRespAdapter "返回資料" {
            tags "Sync"
        }
        care.core.preference -> care.bff.liffRespAdapter "返回設定" {
            tags "Sync"
        }
        care.core.hospitalSvc -> care.bff.liffRespAdapter "返回醫療資訊" {
            tags "Sync"
        }
        care.core.healthDomain -> care.bff.liffRespAdapter "返回健康資訊" {
            tags "Sync"
        }
        care.core.richMenuMgmt -> care.bff.liffRespAdapter "返回 Rich Menu" {
            tags "Sync"
        }
        care.bff.liffRespAdapter -> care.bff.respFormatter "格式化" {
            tags "Sync"
        }
        care.bff.respFormatter -> care.liff "返回 LIFF" {
            tags "Sync"
        }
        
        // --- BFF Webhook Flow ---
        line -> care.bff.webhookCtrl "發送事件" {
            tags "Async"
        }
        care.bff.webhookCtrl -> care.bff.webhookAdapter "轉換格式" {
            tags "Sync"
        }
        care.bff.webhookAdapter -> care.bff.router "路由事件" {
            tags "Sync"
        }
        
        // --- Webhook Router to Core ---
        care.bff.router -> care.core.conv "文字/圖片訊息" {
            tags "Sync"
        }
        care.bff.router -> care.core.videoAnalysis "影片訊息" {
            tags "Sync"
        }
        care.bff.router -> care.core.docProcess "文件訊息" {
            tags "Sync"
        }
        care.bff.router -> care.core.asr "語音訊息" {
            tags "Sync"
        }
        care.bff.router -> care.core.userMgmt "追蹤/取消追蹤" {
            tags "Sync"
        }
        
        // --- Core Response to BFF (Webhook Flow) ---
        care.core.conv -> care.bff.flexAdapter "返回對話" {
            tags "Sync"
        }
        care.core.videoAnalysis -> care.bff.flexAdapter "返回分析" {
            tags "Sync"
        }
        care.core.docProcess -> care.bff.flexAdapter "返回處理結果" {
            tags "Sync"
        }
        care.core.asr -> care.bff.flexAdapter "返回轉文字" {
            tags "Sync"
        }
        care.bff.flexAdapter -> care.bff.lineClient "傳送 Flex" {
            tags "Sync"
        }
        care.bff.lineClient -> line "推送訊息" {
            tags "Async"
        }
        
        // --- Rich Menu Sync ---
        care.core.richMenuMgmt -> care.bff.richMenuAdapter "設定變更通知" {
            tags "Async"
        }
        care.bff.richMenuAdapter -> care.bff.lineClient "同步到 LINE" {
            tags "Sync"
        }
        care.bff.lineClient -> line "更新 Rich Menu" {
            tags "Async"
        }
        
        // --- Core Internal: Conversation Flow ---
        care.core.conv -> care.core.preference "獲取語言偏好" {
            tags "Sync"
        }
        care.core.conv -> care.core.aiResponse "請求 AI 生成" {
            tags "Sync"
        }
        care.core.conv -> care.core.factCheck "需查核時" {
            tags "Sync"
        }
        care.core.conv -> care.db "記錄對話歷史" {
            tags "Sync"
        }
        
        // --- Core Internal: AI Response Flow ---
        care.core.aiResponse -> care.core.preference "獲取 AI 偏好" {
            tags "Sync"
        }
        care.core.aiResponse -> care.core.tts "需語音時" {
            tags "Sync"
        }
        
        // --- Core Internal: Fact Checking ---
        care.core.factCheck -> care.core.aiResponse "修正回覆" {
            tags "Sync"
        }
        
        // --- Core Internal: Content Processing ---
        care.core.videoAnalysis -> care.core.mediaProcess "處理影片" {
            tags "Sync"
        }
        care.core.docProcess -> care.core.mediaProcess "處理文件" {
            tags "Sync"
        }
        
        // --- Core to Storage ---
        care.core.userMgmt -> care.db "CRUD 使用者資料" {
            tags "Sync"
        }
        care.core.preference -> care.db "CRUD 偏好" {
            tags "Sync"
        }
        care.core.healthDomain -> care.db "讀健康資訊、寫紀錄" {
            tags "Sync"
        }
        care.core.hospitalSvc -> care.db "讀醫院資源" {
            tags "Sync"
        }
        care.core.richMenuMgmt -> care.db "存取 Rich Menu 設定" {
            tags "Sync"
        }
        
        // --- Core to External: Taiwanese AI ---
        care.core.aiResponse -> twAI.twApi.llm "台語文字生成" {
            tags "Sync"
        }
        care.core.tts -> twAI.twApi.tts "台語 TTS" {
            tags "Sync"
        }
        care.core.asr -> twAI.twApi.asr "台語 ASR" {
            tags "Sync"
        }
        twAI.twApi.llm -> twAI.twApi.mgr "載入 LLM" {
            tags "Sync"
        }
        twAI.twApi.tts -> twAI.twApi.mgr "載入 TTS" {
            tags "Sync"
        }
        twAI.twApi.asr -> twAI.twApi.mgr "載入 ASR" {
            tags "Sync"
        }
        
        // --- Core to External: MCP Workflows (Async) ---
        care.core.aiResponse -> mcp.mcpApi.rag "RAG 醫療知識" {
            tags "Async"
        }
        care.core.docProcess -> mcp.mcpApi.ocrWf "OCR 識別" {
            tags "Async"
        }
        care.core.mediaProcess -> mcp.mcpApi.videoWf "影片處理" {
            tags "Async"
        }
        care.core.mediaProcess -> mcp.mcpApi.audioWf "音訊處理" {
            tags "Async"
        }
        care.core.factCheck -> mcp.mcpApi.dataWf "資料驗證" {
            tags "Async"
        }
        mcp.mcpApi.rag -> mcp.mcpApi.wfMgr "執行" {
            tags "Sync"
        }
        mcp.mcpApi.docWf -> mcp.mcpApi.wfMgr "執行" {
            tags "Sync"
        }
        mcp.mcpApi.videoWf -> mcp.mcpApi.wfMgr "執行" {
            tags "Sync"
        }
        mcp.mcpApi.audioWf -> mcp.mcpApi.wfMgr "執行" {
            tags "Sync"
        }
        mcp.mcpApi.ocrWf -> mcp.mcpApi.wfMgr "執行" {
            tags "Sync"
        }
        mcp.mcpApi.dataWf -> mcp.mcpApi.wfMgr "執行" {
            tags "Sync"
        }
    }
    
    views {
        styles {
            // --- People ---
            element "Person" {
                shape person
                background #ecf0f1
                color #1f2d3d
                fontSize 38
            }
            
            // --- Software Systems ---
            element "Software System" {
                shape roundedbox
                background #e6f0ff
                color #1f2d3d
                fontSize 36
            }
            element "External" {
                background #f2f2f2
                color #1f2d3d
                opacity 100
                fontSize 34
            }
            
            // --- Containers ---
            element "Container" {
                shape roundedbox
                background #dbe9ff
                color #1f2d3d
                fontSize 34
            }
            element "Database" {
                shape cylinder
                background #dff5e3
                color #1f2d3d
                fontSize 32
            }
            element "Cache" {
                shape cylinder
                background #fdebd0
                color #1f2d3d
                fontSize 32
            }
            
            // --- Components ---
            element "Component" {
                shape roundedbox
                background #ffffff
                color #1f2d3d
                stroke #7f8c8d
                strokeWidth 2
                fontSize 32
            }
            
            // --- Tags ---
            element "Core" {
                background #cfe2ff
                color #1f2d3d
                fontSize 34
            }
            element "Adapter" {
                background #eaf4ff
                color #1f2d3d
                stroke #7aa6d8
                strokeWidth 2
                fontSize 32
            }
            element "AI" {
                background #e6d9f5
                color #1f2d3d
            }
            element "Async" {
                background #fde2c7
                color #1f2d3d
            }
            
            // --- Relationships ---
            relationship "Relationship" {
                color #2c3e50
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