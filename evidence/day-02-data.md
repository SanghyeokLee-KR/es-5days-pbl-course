# Day 2 실제 실행 증거

공통과 개인을 구분한다. 실행하지 않은 결과는 미실행으로 적는다. 비밀번호/인증 헤더를 기록하지 않는다.

## V1-T09-C/P 환경

- 실제 node 이름/버전/master: `es01`/`es02`/`es03`, Elasticsearch 9.5.0 (master 노드는 별도로 `GET /_cat/master`를 확인하지 않아 미확인)
- products 존재 여부 / 실제 CAT 값: 존재, 10,000건
- 개인 index 이름: `shop-logs`

## V1-T12-C/P 생성/조회

- 공통/개인 구분, 대상 index: 개인, `shop-logs`
- 신규 생성 또는 기존 확인: 신규 생성
- 요청과 실제 응답(settings/mapping/shards): 1 shard/1 replica, `dynamic: strict`, field 10개. Shard 배치(`GET /_cat/shards/shop-logs?v`)는 `0 p STARTED` es01, `0 r STARTED` es02로 primary·replica 모두 정상(UNASSIGNED 없음)
- 기대/실제 비교: 일치

## V1-T13-C/P 분석

| 입력 | 방식(standard/field) | 예상 token | 실제 token/position | 차이 이유 |
|---|---|---|---|---|
| "시간 초과" | standard | 시간, 초과 | 시간, 초과 | 검색어 자체는 공백 구분이라 그대로 분리됨 |
| "시간 초과" | whitespace | 시간, 초과 | 시간, 초과 | 위와 동일 |
| "재시도" | standard | 재시도 | 재시도 | 단독 검색어라 그대로 한 token |
| "재시도" | whitespace | 재시도 | 재시도 | 위와 동일 |
| "정상적으로 완료" | standard | 정상적으로, 완료 | 정상적으로, 완료 | 공백 기준 분리로 동일 |
| "정상적으로 완료" | whitespace | 정상적으로, 완료 | 정상적으로, 완료 | 위와 동일 |

개인 검색어3개를 두 방식으로 각각 기록했다. 요청은 루트 `requests.http`에 보존한다.

`nori` 플러그인이 없어 `standard`(`log_message_analyzer`)와 `whitespace`를 비교했다. 검색어 자체는 두 analyzer가 동일하게 나오지만, 실제 문서 `message` 원문을 분석하면 다르다 — "요청 처리 중 재시도가 발생했습니다."는 `재시도가`가 조사 "가"까지 붙어 한 token으로 묶여서, 검색어 "재시도"(token: `재시도`)로 `match` 검색하면 일치하지 않아 0건이 나온다. 3교시 실습(`evidence/day-03-practice/period-02-term-match.md`)에서 발견했던 현상의 원인을 여기서 확정했다. 같은 이유로 "시간 초과되었습니다."의 `초과되었습니다`도 한 token이라 "초과"만으로는 일치하지 않는다. `nori` 같은 형태소 분석기가 없어 조사·어미가 분리되지 않는 것이 이 index의 공통 한계다.

## V1-T14-C/P CRUD

- 대상 index / 임시 ID / 출발 count: `shop-logs` / `LOG-TEST01` / 1000

| 단계 | 예상 result | 실제 result | 실제 source/변경·유지 field |
|---|---|---|---|
| 생성 | created | created, `_version: 1` | 입력한 source 그대로 |
| 조회 | found | `found: true` | `_source` 일치 |
| 수정/재조회 | updated | updated, `_version: 2` | `log_level → WARN`, `duration_ms → 980`로 변경 확인 |
| 삭제/재조회 | deleted, `found: false` | deleted, `_version: 3` / `found: false` | - |

- 삭제 뒤 found/count: `found: false`, 종료 count 1000(생성·삭제로 원상 복귀)
- 선택 noop/not_found 관찰: `LOG-TEST04`를 생성한 뒤 동일 값(`log_level: INFO`)으로 update → `result: noop`, `_shards.total: 0`. 첫 번째 DELETE는 `deleted`, 두 번째 DELETE는 `not_found`

## V1-T15-C/P 생성·적재

- 생성 설정/명령/건수/seed: `generate-data.ps1`, 1,000건(표본 30건 별도 보존), seed `20260901`
- 로컬 검사 결과: `validate-data.ps1` → `LOCAL CHECK PASS: 1000 documents, unique IDs, target index and NDJSON verified.`
- 표본 ID/field/조건 사례 확인: `-FixedDocumentsFile ..\sample-documents.json`으로 대표 3건을 `LOG-000001`~`003`에 그대로 삽입했다. `GET /shop-logs/_doc/LOG-000002`로 타임아웃 ERROR 문서가 실제 색인됐음을 확인했다.
- 실제 Bulk 결과 / 현재 단계 / S67에서 이어 할 작업: `load-data.ps1` → `PASS: Bulk item errors=false. Actual count=1000, generated=1000.` ES 실제 `_count`도 1000으로 일치. 다음은 Day 3 검색 검증.

## V1-T16-C simulate

`product-cleanup` pipeline(재고 기본값 설정, `brand_name`→`brand` 이름 변경, `temp`·`raw_price` 제거)을 생성하고 4가지 입력으로 `_simulate`를 실행했다. `_simulate`는 저장하지 않는다.

| 입력 사례 | 예상 변화/오류 | 실제 변화/오류 | 저장 여부 |
|---|---|---|---|
| Samsung(`in_stock` 없음) | `in_stock`이 `true`로 채워지고 `brand_name`→`brand`, `temp`·`raw_price` 제거 | `in_stock: true`, `brand: "Samsung"`, `temp`·`raw_price` 없음 — 예상과 일치 | 저장 안 함(simulate) |
| Apple(`category` 있음) | 위와 동일, `category`는 보존 | `brand: "Apple"`, `category: "전자기기"` 유지, `temp`·`raw_price` 제거 — 일치 | 저장 안 함 |
| `in_stock: false` 명시 | `set` processor가 `override:false`라 기존 값 유지해야 함 | `in_stock: false` 그대로 유지 — 일치 | 저장 안 함 |
| `temp` 필드 누락 | `remove` processor가 없는 field를 지우려다 오류 예상 | `illegal_argument_exception: field [temp] not present as part of path [temp]` — 예상대로 오류 | 저장 안 함(오류로 중단) |

## V1-T16-P 필수 개인 완료

- 개인 index / 생성 건수 / 실제 ES count: `shop-logs` / 1,000 / 1,000
- 분류 terms / 숫자 stats / 필요한 날짜 범위: `log_level` INFO 711 / WARN 188 / ERROR 101, `service_name` 4개 서비스 239~261건으로 고른 분포; `duration_ms` min 50.0 / max 4994.0 / avg 2557.98; 날짜 범위 2026-08-18~2026-09-01
- 계획과 실제 분포 차이 이유: 목표 비율(70/20/10)과 실측 비율(71.1/18.8/10.1)이 근접해 별도 원인 조사 불필요
- 선택 pipeline 실제 단건/GET/정리 결과(미구현이면 해당 없음): 해당 없음(미적용, `docs/pipeline-decision.md` 참고)

## 오류·재검증

| 요청/파일 | 오류 | 수정 | 실제 재실행 결과 | 다음 조치 |
|---|---|---|---|---|
| `data/pbl-data-template/my-data-settings.ps1` | UTF-8 BOM이 없어 Windows PowerShell 5.1이 dot-sourcing 시 한글 리터럴을 잘못 읽어 `message` field가 깨짐 → "시간 초과" 검색이 1건만 반환 | 같은 파일을 UTF-8 BOM 있는 인코딩으로 재저장 | 데이터 재생성·재검증·재적재 후 동일 쿼리에서 100건 반환 | Day 3 검색 검증(`evidence/day-03-search.md`)에서 재확인 완료 |

## 제출

- commit hash / 현재 branch: 이 커밋 직후 `git log -1`로 확인 (브랜치: `main`)
- GitHub에서 확인한 동일 commit / push 실패라면 원인: push 후 `git log origin/main -1`로 대조 확인
- 미완료와 다음 요청: 없음. Day 4 aggregation·Dashboard로 이어감
