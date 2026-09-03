# 개인 생성 규칙

## V1-T15-P 설정

- index / 업무 ID field / ID prefix: `shop-logs` / `log_id` / `LOG-`
- 첫 건수1000 / SampleCount30 / Seed: 1000 / 30 / `20260901`
- 코드·환경·설정 파일 위치: `data/pbl-data-template/generator/generate-data.ps1`, `data/pbl-data-template/my-data-settings.ps1`

| field | Kind | 후보/범위/비율 | 결측 정책 | mapping type | 연결 질문 |
|---|---|---|---|---|---|
| `log_id` | id | `LOG-` + 6자리 순번 | 없음 | keyword | 전체 |
| `timestamp` | date | 2026-08-18 ~ 2026-09-01 균등 | 없음 | date | Q1, Q3 |
| `service_name` | choice | order-api / payment-api / catalog-api / auth-api 균등 | 없음 | keyword | Q2, Q3 |
| `log_level` | weighted_choice | INFO 70%, WARN 20%, ERROR 10% | 없음 | keyword | Q2, Q3 |
| `logger_name` | template | `com.shop.{service_name}.RequestHandler` | 없음 | keyword | - |
| `message` | weighted_choice | 정상 70%, 재시도 15%, 시간 초과 10%, 오류 5% | 없음 | text | Q1, Q3 |
| `exception_class` | choice | ERROR 비율(10%)에 맞추고 나머지는 비움 | 90% 결측 | keyword | - |
| `http_status` | weighted_choice | 200 75%, 404 5%, 500 10%, 504 10% | 없음 | integer | - |
| `duration_ms` | integer | 50 ~ 5000ms 균등 | 없음 | integer | Q3 |
| `trace_id` | template | `TRC-{sequence}` | 없음 | keyword | - |

## 포함·제외·경계

| 질문 | 포함 사례 | 제외 사례 | 경계 사례 | 고정 사례 사용 여부 | 확인 요청 |
|---|---|---|---|---|---|
| "시간 초과" 언급 로그 검색 | message가 "게이트웨이 응답이 3000ms 후 시간 초과되었습니다."인 문서 (약 10%) | "요청 처리가 정상적으로 완료되었습니다."인 문서 (약 70%) | "시간"만 있고 "초과"가 없는 문장은 안 만들었다 | 예 (`LOG-000002`) | Day3에서 100건 확인 |
| 결제 서비스의 느린 ERROR | payment-api, ERROR, duration_ms 3000 초과 (`duration_ms=3021`) | 같은 조건인데 duration_ms가 3000 이하인 문서 | duration_ms가 딱 3000인 문서는 균등분포라 보장이 안 된다 | 예 (`LOG-000002`) | Day3에서 3건 확인 |
| 서비스별 에러 요약 | log_level이 ERROR인 약 100건, 4개 서비스에 흩어짐 | log_level이 INFO인 약 700건 | 서비스 하나에 ERROR가 0건일 수도 있다. 서비스당 25건쯤이라 가능성은 낮다 | 아니오 | Day3에서 payment-api ERROR 20건 확인 |

- FixedDocumentsFile을 쓰면 업무 ID를 생성 ID로 다시 배정함을 확인: 확인함. `LOG-000001`~`003`으로 다시 배정됐다
- 복합 객체/연관 분포 등 미지원 요구와 선택한 범위/대안: 생성기가 field끼리 조건부로 엮는 걸 지원 안 한다. `log_level=ERROR`랑 `exception_class`, `http_status`가 따로 뽑힌다. 그냥 각각 독립 확률로 두고 목표 비율만 맞췄다
- 생성·적재·검증 명령: `generate-data.ps1` → `validate-data.ps1` → `load-data.ps1`
- 실제 분포와 예상의 차이 / 다음 수정: validate PASS(1000건, ID 중복 없음), 적재 후 `_count` 1000건. log_level은 목표 70/20/10에 실측 71.1/18.8/10.1이 나왔다. duration_ms는 min 50.0, max 4994.0, avg 2557.98. 따로 고칠 건 없었다
