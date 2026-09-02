# Day 3 검색 구현·품질 검증 산출물

## 1. 실행 기준

- 개인 index: `shop-logs`
- 수업 시작 시 실제 `_count`: 1000
- 개인 요청 파일: `requests.http` (`V1-T17-P`~`V1-T21-P` 구간)
- 검색 품질 주 문서: `docs/quality-test.md`
- 실행 환경·시각: Windows 11, Docker Desktop, Elasticsearch 9.5.0, Kibana 9.5.0 / 2026-09-01

## 2. 검색 질문과 요구사항

| 요청 ID | 사용자 질문 | 검색 field·검색어 | 정확 조건·범위 | 정렬 | 표시·highlight |
|---|---|---|---|---|---|
| V1-T18-P-2 전문 검색 | "시간 초과"가 언급된 로그를 찾고 싶다 | `message`, "시간 초과" | 없음 | 없음 | 없음 |
| V1-T19-P-1 정확 조건 | 결제 서비스에서 난 ERROR만 보고 싶다 | 없음 | `service_name=payment-api`, `log_level=ERROR` | 없음 | 없음 |
| V1-T21-P-1 bool/filter 통합 | 결제 서비스에서 시간 초과된 ERROR 중 3초 이상인 것을 최근·느린 순으로 보고 싶다 | `message`, "시간 초과" | `service_name=payment-api`, `log_level=ERROR`, `duration_ms>=3000` | `duration_ms desc`, `timestamp desc` | `message` highlight |

## 3. 실행 전 기대 기준

| 요청 ID | 기대 문서 ID·이유 | 제외 문서 ID·이유 | 의도한 0건 조건 | 경계 포함·제외 기준 |
|---|---|---|---|---|
| V1-T18-P-2 | `LOG-000002`(대표 3건 중 타임아웃 ERROR) 포함, message에 "시간 초과" 문자열이 있는 약 100건 | `LOG-000001`(정상 메시지), `LOG-000003`(재시도 메시지) | - | - |
| V1-T19-P-1 | `LOG-000002` 포함, service_name=payment-api·log_level=ERROR인 문서 | `LOG-000001`(order-api), 다른 서비스이거나 log_level이 ERROR가 아닌 문서 | - | - |
| V1-T21-P-1 | `LOG-000002`(duration_ms=3021) 포함 | duration_ms가 3000 미만인 payment-api ERROR 문서 | `log_id=__DAY03_INTENTIONAL_ZERO__`는 0건이어야 함(V1-T21-P-2) | `gte:3000`과 `gt:3000` 결과가 같으면 경계값 3000인 문서가 없다는 뜻 |

## 4. 실제 결과와 판정

| 요청 ID | `hits.total.value` | 상위 3개 ID | 조건·경계 통과 | 관련/보류/무관과 근거 | 판정 |
|---|---:|---|---|---|---|
| V1-T18-P-2 | 100 | LOG-000002, LOG-000016, LOG-000036 | 해당 없음 | 관련 — 상위 3건 모두 message에 "시간 초과되었습니다" 포함 | 통과 |
| V1-T19-P-1 | 20 | (확인한 5건 모두 payment-api·ERROR) | 통과 — 확인한 문서 전부 두 조건 만족 | 관련 — 정확 조건이라 전건이 의도와 일치 | 통과 |
| V1-T21-P-1 | 3 | LOG-000521, LOG-000718, LOG-000002 | 통과 — 3건 모두 duration_ms≥3000, service_name=payment-api, log_level=ERROR | 관련 — 3건 모두 실제 타임아웃 메시지 | 통과 |

## 5. 조건 제거·변형 실험

| 기준 요청 | 바꾼 한 요소 | 변경 전 total·대표 ID | 변경 후 total·새로 들어온/빠진 ID | 관찰한 역할 |
|---|---|---|---|---|
| V1-T19-P-2(경계) | `range` 조건을 `gte:3000` → `gt:3000` | `gte`: total 8, LOG-000002 포함 | `gt`: total 8, 동일 8건 (변화 없음) | duration_ms 값 중 정확히 3000인 문서가 없어 경계 포함·제외가 결과에 영향을 주지 않음을 확인. range 경계는 실제 데이터 분포에 따라 결과가 달라지거나 같을 수 있다는 것을 보여준다. |

## 6. 실패 원인 진단

- 문제: V1-T18-P-2("시간 초과" 전문 검색)에서 기대치인 약 100건이 아니라 1건만 반환됐다.
- 1차 원인 분류: data (생성 단계의 인코딩 문제)
- 확인한 실제 근거: `Get-Content -Encoding UTF8`로 원본 NDJSON 파일을 직접 읽었을 때 `LOG-000004`부터 `message` field가 `"?붿껌 泥섎━ 以??ъ떆?꾧? 諛쒖깮?덉뒿?덈떎."`처럼 깨져 있음을 확인했다. `sample-documents.json`에서 온 `LOG-000001~003`은 정상이었다.
- 다음 확인 또는 변경: `my-data-settings.ps1`이 UTF-8 BOM 없이 저장돼 있어, Windows PowerShell 5.1이 dot-sourcing 시 한글 리터럴을 시스템 코드페이지로 잘못 해석한 것으로 판단했다.

## 7. 개선 전후

| 문제 | 추정 원인 | 변경한 한 요소 | 같은 조건으로 재실행한 결과 | 개선 판정과 근거 |
|---|---|---|---|---|
| "시간 초과" 검색이 1건만 반환됨 | `my-data-settings.ps1`에 UTF-8 BOM 없음 | 같은 파일을 UTF-8 BOM 있음으로 다시 저장 | 데이터 재생성·재검증·재적재 후 동일 쿼리 실행 시 100건 반환 | 개선 — 목표 비율(10%)과 정확히 일치하는 100건으로 정상화됨 |

## 8. 완료 체크

- [x] 전문 검색 요청 1개 (V1-T18-P-2)
- [x] 정확 조건 요청 1개 (V1-T18-P-1, V1-T19-P-1)
- [x] bool/filter 요청 1개 (V1-T19-P-1, V1-T21-P-1)
- [x] filter 2개 이상 (V1-T21-P-1: service_name·log_level·duration_ms 3개)
- [x] sort 2개 (V1-T20-P: duration_ms desc, timestamp desc)
- [x] highlight 1개 (V1-T20-P, V1-T21-P-1: message)
- [x] 의도한 0건 요청 1개 (V1-T21-P-2)
- [x] 상위 3건 사람 평가 (섹션 4)
- [x] 개선 1건과 전후 결과 (섹션 7)
- [x] README의 기능 목록·실행 경로 동기화
- [x] 최종 commit SHA: 이 커밋 직후 `git log -1`로 확인

## 9. 교시별 실습 진행 상황

- 1~4교시 (`evidence/day-03-practice/period-01-search-api.md` ~ `period-04-filter-range.md`): 작성 완료
- 5~8교시 (`period-05-bool.md`, `period-06-sort-highlight.md`, `period-07-quality.md`, `period-08-integration.md`): **미수행**. 배포본 양식만 복사해 둔 상태다.
