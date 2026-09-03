# Day 2 실제 실행 증거

공통과 개인을 구분한다. 실행하지 않은 결과는 미실행으로 적는다. 비밀번호/인증 헤더를 기록하지 않는다.

## V1-T09-C/P 환경

- 실제 node 이름/버전/master: es01, es02, es03 / 9.5.0 / master는 es03 (Day 1에 `GET /_cat/nodes?v`로 확인)
- products 존재 여부 / 실제 CAT 값: 있음, 10,000건
- 개인 index 이름: `shop-logs`

## V1-T12-C/P 생성/조회

- 공통/개인 구분, 대상 index: 개인, `shop-logs`
- 신규 생성 또는 기존 확인: 새로 생성
- 요청과 실제 응답(settings/mapping/shards): shard 1개, replica 1개, `dynamic: strict`, field 10개. `GET /_cat/shards/shop-logs?v` 결과는 `0 p STARTED` es01, `0 r STARTED` es02. UNASSIGNED 없음
- 기대/실제 비교: 같음

## V1-T13-C/P 분석

| 입력 | 방식(standard/field) | 예상 token | 실제 token/position | 차이 이유 |
|---|---|---|---|---|
| "시간 초과" | standard | 시간, 초과 | 시간, 초과 | 검색어가 이미 띄어쓰기로 나뉘어 있어서 |
| "시간 초과" | whitespace | 시간, 초과 | 시간, 초과 | 위와 같음 |
| "재시도" | standard | 재시도 | 재시도 | 한 단어라 그대로 |
| "재시도" | whitespace | 재시도 | 재시도 | 위와 같음 |
| "정상적으로 완료" | standard | 정상적으로, 완료 | 정상적으로, 완료 | 공백 기준으로 잘림 |
| "정상적으로 완료" | whitespace | 정상적으로, 완료 | 정상적으로, 완료 | 위와 같음 |

개인 검색어3개를 두 방식으로 각각 기록한다. 요청은 루트 requests.http에 보존한다.

nori가 없어서 standard(`log_message_analyzer`)랑 whitespace를 비교했다. 검색어만 보면 둘이 똑같이 나오는데, 실제 문서 message를 분석하면 다르다. "요청 처리 중 재시도가 발생했습니다."를 넣으면 `재시도가`가 조사까지 붙어서 한 덩어리로 잡힌다. 그래서 "재시도"로 match를 걸면 0건이 나온다. 3교시 실습에서 왜 안 나오나 했던 게 이거였다. "시간 초과되었습니다."의 `초과되었습니다`도 마찬가지라 "초과"만으로는 안 걸린다.

## V1-T14-C/P CRUD

- 대상 index / 임시 ID / 출발 count: `shop-logs` / `LOG-TEST01` / 1000

| 단계 | 예상 result | 실제 result | 실제 source/변경·유지 field |
|---|---|---|---|
| 생성 | created | created, `_version: 1` | 넣은 그대로 |
| 조회 | found | `found: true` | `_source` 같음 |
| 수정/재조회 | updated | updated, `_version: 2` | `log_level`이 WARN으로, `duration_ms`가 980으로 바뀜 |
| 삭제/재조회 | deleted, `found: false` | deleted, `_version: 3` / `found: false` | - |

- 삭제 뒤 found/count: `found: false`, count는 다시 1000
- 선택 noop/not_found 관찰: `LOG-TEST04`를 만들고 원래 값(`log_level: INFO`) 그대로 update하니 `result: noop`, `_shards.total: 0`이 나왔다. DELETE는 처음엔 deleted, 두 번째는 not_found

## V1-T15-C/P 생성·적재

- 생성 설정/명령/건수/seed: `generate-data.ps1`, 1,000건(표본 30건 따로), seed `20260901`
- 로컬 검사 결과: `validate-data.ps1` → `LOCAL CHECK PASS: 1000 documents, unique IDs, target index and NDJSON verified.`
- 표본 ID/field/조건 사례 확인: `-FixedDocumentsFile ..\sample-documents.json`로 대표 3건을 `LOG-000001`~`003`에 넣었다. `GET /shop-logs/_doc/LOG-000002`로 타임아웃 ERROR 문서가 들어간 걸 봤다
- 실제 Bulk 결과 / 현재 단계 / S67에서 이어 할 작업: `load-data.ps1` → `PASS: Bulk item errors=false. Actual count=1000, generated=1000.` ES `_count`도 1000. 다음은 Day 3 검색

## V1-T16-C simulate

`product-cleanup` pipeline(재고 기본값, `brand_name`→`brand`, `temp`·`raw_price` 제거)을 만들고 4가지로 `_simulate`를 돌렸다. simulate는 저장이 안 된다.

| 입력 사례 | 예상 변화/오류 | 실제 변화/오류 | 저장 여부 |
|---|---|---|---|
| Samsung(`in_stock` 없음) | `in_stock`이 true로 채워지고 `brand_name`이 `brand`로, `temp`·`raw_price` 삭제 | `in_stock: true`, `brand: "Samsung"`, `temp`·`raw_price` 없음 | 저장 안 됨 |
| Apple(`category` 있음) | 위랑 같고 `category`는 남음 | `brand: "Apple"`, `category: "전자기기"` 그대로, `temp`·`raw_price` 삭제 | 저장 안 됨 |
| `in_stock: false` 명시 | `override:false`라 원래 값이 남아야 함 | `in_stock: false` 그대로 | 저장 안 됨 |
| `temp` 필드 누락 | 없는 field를 지우려다 오류 날 듯 | `illegal_argument_exception: field [temp] not present as part of path [temp]` | 저장 안 됨 |

## V1-T16-P 필수 개인 완료

- 개인 index / 생성 건수 / 실제 ES count: `shop-logs` / 1,000 / 1,000
- 분류 terms / 숫자 stats / 필요한 날짜 범위: log_level INFO 711, WARN 188, ERROR 101. service_name은 4개 서비스가 239~261건. duration_ms min 50.0, max 4994.0, avg 2557.98. 날짜는 2026-08-18~2026-09-01
- 계획과 실제 분포 차이 이유: 목표 70/20/10에 실측 71.1/18.8/10.1이라 거의 같다
- 선택 pipeline 실제 단건/GET/정리 결과(미구현이면 해당 없음): 해당 없음. `docs/pipeline-decision.md`에서 미적용으로 정함

## 오류·재검증

| 요청/파일 | 오류 | 수정 | 실제 재실행 결과 | 다음 조치 |
|---|---|---|---|---|
| `data/pbl-data-template/my-data-settings.ps1` | UTF-8 BOM이 없어서 PowerShell 5.1이 한글을 잘못 읽었다. message가 깨져서 "시간 초과" 검색이 1건만 나옴 | BOM 있는 UTF-8로 다시 저장 | 다시 만들고 적재하니 같은 쿼리에서 100건 | Day 3에서 다시 확인 |

## 제출

- commit hash / 현재 branch: 이 커밋 직후 `git log -1`로 확인 (브랜치 `main`)
- GitHub에서 확인한 동일 commit / push 실패라면 원인: push 후 `git log origin/main -1`로 대조
- 미완료와 다음 요청: 없음. Day 4로 넘어감
