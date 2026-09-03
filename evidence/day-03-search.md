# Day 3 검색 구현·품질 검증 산출물

> 공통 쇼핑몰 답을 복사하지 않고 자신의 PBL index와 실제 결과를 기록합니다. 실행하지 않은 결과는 완료로 표시하지 않습니다.

## 1. 실행 기준

- 개인 index: `shop-logs`
- 수업 시작 시 실제 `_count`: 1000
- 개인 요청 파일: `requests.http` (`V1-T17-P`~`V1-T21-P` 구간)
- 검색 품질 주 문서: `docs/quality-test.md`
- 실행 환경·시각: Windows 11, Docker Desktop, Elasticsearch 9.5.0, Kibana 9.5.0 / 2026-09-01

## 2. 검색 질문과 요구사항

| 요청 ID | 사용자 질문 | 검색 field·검색어 | 정확 조건·범위 | 정렬 | 표시·highlight |
|---|---|---|---|---|---|
| Q01 전문 검색 (`V1-T18-P-2`) | "시간 초과"가 언급된 로그를 찾고 싶다 | `message`, "시간 초과" | 없음 | 없음 | 없음 |
| Q02 정확 조건 (`V1-T19-P-1`) | 결제 서비스에서 난 ERROR만 보고 싶다 | 없음 | `service_name=payment-api`, `log_level=ERROR` | 없음 | 없음 |
| Q03 bool/filter (`V1-T21-P-1`) | 결제 서비스에서 시간 초과된 ERROR 중 3초 이상인 것을 최근·느린 순으로 보고 싶다 | `message`, "시간 초과" | `service_name=payment-api`, `log_level=ERROR`, `duration_ms>=3000` | `duration_ms desc`, `timestamp desc` | `message` highlight |

## 3. 실행 전 기대 기준

| 요청 ID | 기대 문서 ID·이유 | 제외 문서 ID·이유 | 의도한 0건 조건 | 경계 포함·제외 기준 |
|---|---|---|---|---|
| Q01 | `LOG-000002`(타임아웃 ERROR)와 message에 "시간 초과" 있는 100건쯤 | `LOG-000001`(정상), `LOG-000003`(재시도) | - | - |
| Q02 | `LOG-000002`와 payment-api + ERROR 문서 | `LOG-000001`(order-api), 서비스가 다르거나 ERROR 아닌 문서 | - | - |
| Q03 | `LOG-000002`(duration_ms 3021) | duration_ms 3000 미만인 payment-api ERROR | `log_id=__DAY03_INTENTIONAL_ZERO__` → 0건 (`V1-T21-P-2`) | `gte:3000`과 `gt:3000`이 같으면 딱 3000인 문서 없음 |

## 4. 실제 결과와 판정

| 요청 ID | `hits.total.value` | 상위 3개 ID | 조건·경계 통과 | 관련/보류/무관과 근거 | 판정 |
|---|---:|---|---|---|---|
| Q01 | 100 | LOG-000002, LOG-000016, LOG-000036 | 해당 없음 | 관련. 상위 3건 다 "시간 초과되었습니다" 포함 | 통과 |
| Q02 | 20 | (확인한 5건 다 payment-api, ERROR) | 통과 | 관련. 정확 조건이라 전건 일치 | 통과 |
| Q03 | 3 | LOG-000521, LOG-000718, LOG-000002 | 통과. 3건 다 duration_ms 3000 이상, payment-api, ERROR | 관련. 3건 다 타임아웃 메시지 | 통과 |

## 5. 조건 제거·변형 실험

| 기준 요청 | 바꾼 한 요소 | 변경 전 total·대표 ID | 변경 후 total·새로 들어온/빠진 ID | 관찰한 역할 |
|---|---|---|---|---|
| Q03 경계(`V1-T19-P-2`) | `gte:3000` → `gt:3000` | `gte`: 8건, LOG-000002 포함 | `gt`: 8건, 변화 없음 | duration_ms가 딱 3000인 문서가 없어 경계 포함 여부가 결과에 영향 없음 |

## 6. 실패 원인 진단

- 문제: Q01에서 100건쯤 나와야 하는데 1건
- 1차 원인 분류: data (생성 단계의 인코딩 문제)
- 확인한 실제 근거: `Get-Content -Encoding UTF8`로 NDJSON을 열어보니 `LOG-000004`부터 message가 `"?붿껌 泥섎━ 以??ъ떆?꾧? 諛쒖깮?덉뒿?덈떎."`로 깨짐. `sample-documents.json`에서 온 `LOG-000001~003`만 정상
- 다음 확인 또는 변경: `my-data-settings.ps1`이 BOM 없이 저장됨. PowerShell 5.1이 dot-sourcing 때 한글을 시스템 코드페이지로 읽음

## 7. 개선 전후

| 문제 | 추정 원인 | 변경한 한 요소 | 같은 조건으로 재실행한 결과 | 개선 판정과 근거 |
|---|---|---|---|---|
| "시간 초과" 검색이 1건 | `my-data-settings.ps1`에 UTF-8 BOM 없음 | BOM 넣어 재저장 | 재생성·재적재 후 100건 | 개선. 목표 10%와 일치 |

## 8. 완료 체크

- [x] 전문 검색 요청 1개 (Q01 / `V1-T18-P-2`)
- [x] 정확 조건 요청 1개 (Q02 / `V1-T19-P-1`)
- [x] bool/filter 요청 1개 (Q03 / `V1-T21-P-1`)
- [x] filter 2개 이상 (Q03: service_name, log_level, duration_ms 3개)
- [x] sort 2개 (`V1-T20-P`: duration_ms desc, timestamp desc)
- [x] highlight 1개 (`V1-T20-P`, Q03: message)
- [x] 의도한 0건 요청 1개 (`V1-T21-P-2`)
- [x] 상위 3건 사람 평가 (섹션 4)
- [x] 개선 1건과 전후 결과 (섹션 7)
- [x] README의 기능 목록·실행 경로 동기화
- [x] 최종 commit SHA: 이 커밋 직후 `git log -1`로 확인
