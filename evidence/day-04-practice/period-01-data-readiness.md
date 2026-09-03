# 1교시 연습 — Data View·Discover·KQL·데이터 준비 상태

- 필수 권장 시간: 38분
- 선택 도전: 7분
- 제출 상태 확인: 5분
- 시작 기준: Kibana 접속 가능
- 화면 순서: [Data View·Discover 상세 가이드](../../day-04/KIBANA_9_5_STEP_BY_STEP.md#1-data-view-만들기-또는-기존-data-view-확인하기)

## (공통·필수) 문제 1 — Dashboard를 만들 수 있는 데이터인지 확인

강사가 지정한 `products` Data View를 선택하고 다음 항목을 확인하세요.

- index pattern: `products`
- time field: `created_at`
- 실제 field: `product_id`, `name`, `category`, `brand`, `price`, `in_stock`, `created_at`
- Discover 전체 문서 수: 20,000

### 결과 입력

- 선택한 Data View 이름: 쇼핑몰 상품 데이터
- index pattern: `products`
- time field: `created_at`
- 확인한 7개 field: `product_id`, `name`, `category`, `brand`, `price`, `in_stock`, `created_at`
- 사용한 절대 시간 범위: `Jul 1, 2025 @ 09:00` ~ `Sep 30, 2026 @ 09:00` (생성 구간 2025-08~2026-08보다 넓게)
- Discover 실제 문서 수: 10,000 (`GET /products/_count`와 동일)
- 정상/보류/오류: YELLOW
- 판정 근거: 가이드 기준 20,000, 실제 배포본 10,000. `day-02/data/generated/products-10000.ndjson`, `generate-products.ps1` 기본 `$Count=10000`, `RELEASE_MANIFEST.md` Day2 v1 "합성10000건". 교재와 데이터 버전 차이(적재 오류 아님)
- 캡처 파일: `evidence/dashboard-discover.png` (Data View, 절대 시간 범위, `Documents (10,000)`, 7개 field 열)

`Last 1 year`로 두면 9,818건, 위 절대 범위로 바꾸면 10,000건.

## (공통·필수) 문제 2 — KQL 적용 전후를 비교

Discover의 전체 20,000건 상태에서 다음 KQL을 실행하세요.

```text
in_stock : false
```

결과를 기록한 뒤 KQL을 지우고 전체 상태로 복구하세요.

### 비교 결과

| 확인 항목 | 적용 전 | 적용 후 | KQL 제거 후 |
|---|---:|---:|---:|
| 문서 수 | 10,000 | 1,531 | 10,000 |

- 적용 후 대표 문서 ID 2개: `P-03985`(MobiCore 컴팩트 노이즈 캔슬링 헤드폰, 311,500원), `P-09246`(SkinNote 컴팩트 세럼, 83,600원)
- `in_stock` 값 확인: 둘 다 `false`
- 복구 성공 여부: 예. `Documents (10,000)`으로 복구
- 캡처 파일: `evidence/dashboard-discover-kql.png` (KQL `in_stock : false`, `Documents (1,531)`)
- KQL이 데이터를 삭제한 것인가? 이유: 아니다. 검색 조건일 뿐이고, 조건을 지우면 10,000으로 돌아온다.

## (진단·필수) 문제 3 — 0건 또는 일부 데이터만 보이는 상황 복구

다음 상황을 가정합니다.

> Discover에서 데이터가 0건이거나 예상보다 적게 보인다. index가 지워졌다고 단정하지 않고 원인을 확인한다.

아래 순서로 현재 화면을 점검하세요.

1. 시간 범위
2. 선택한 Data View
3. KQL 입력
4. filter pill
5. field가 실제 mapping에 존재하는지

실제 화면에서 조건 하나를 일부러 적용해 건수를 줄였다가 다시 복구해도 됩니다.

### 진단 기록

가정이 아니라 Day4 초반 실제 상황.

- 재현한 증상: 전체 상품 수 Metric이 1로 표시
- 마지막 정상 상태: Lens에서 Data View `products` 선택, Metric `Count of records` 넣은 직후
- 확인한 항목과 순서: 1) 시간 범위 → `Aug 22, 2026 @ 12:36 ~ 14:35`(2시간)로 좁게 설정됨 2) Data View → `products` 정상 3) KQL 없음 4) filter pill 없음 5) field mapping 정상
- 발견한 원인: 시간 범위가 실제 `created_at` 분포(2025-08~2026-08)와 안 겹치는 좁은 절대 구간. index나 mapping 문제 아님
- 수정한 내용: 시간 범위를 `Last 1 year`로 확장
- 수정 후 문서 수: 9,818 (182건이 `Last 1 year` 밖)
- 다음부터 먼저 확인할 항목: 시간 범위(index 상태보다 먼저)
- 캡처 파일: 없음

## (개인·필수) 문제 4 — 내 데이터 준비 상태 카드

자기 index 또는 준비 중인 데이터에서 Dashboard 질문 하나를 정하고 필요한 field를 점검하세요. 개인 Data View가 아직 없다면 mapping·샘플 문서로 판단합니다.

### 개인 답안

- 내 주제: 쇼핑몰 백엔드 log4j 로그 트러블슈팅 검색 시스템
- 한 문서가 의미하는 대상 또는 사건: log4j2 JSON Layout으로 남은 로그 이벤트 1건
- Dashboard 사용자: 백엔드 운영·장애 대응 담당자
- 사용자가 내릴 판단: 어떤 예외·상태코드를 우선 조치할지
- 첫 분석 질문: 전체 로그가 몇 건이고 레벨(INFO/WARN/ERROR) 비율은 어떤가
- 필요한 field: `log_level`
- 각 field의 mapping type: `keyword`
- 실제 존재 여부: 있음
- 데이터 문서 수: 1,000 (`GET /shop-logs/_count`)
- A 개인 데이터 사용 / B 공통 products 사용+보강 설계 / C 공통 실습+개인 청사진 중 선택: A
- 선택 이유: `shop-logs`에 `log_level`, `exception_class`, `http_status`, `duration_ms`가 이미 있음
- 부족한 데이터와 다음 행동: 없음. `service_name` 필터/Control은 안 만듦(`evidence/day-04/dashboard-review.md`)

## (선택 도전) 문제 5 — 서로 다른 KQL 3개 설계

`products`에서 category, price, in_stock 중 서로 다른 field를 사용한 KQL 3개를 만들고, 한 번에 한 조건만 실행하세요.

| KQL | 질문 | 결과 수 | 대표 문서 | 조건 제거 후 20,000 복구 |
|---|---|---:|---|---|
| `category : "전자기기"` | 전자기기 카테고리는 몇 건인가 | 1,250 | P-00001(Auralis 키보드) | 제거 후 10,000(가이드 기준 20,000과는 다름, 위 문제1 참고) |
| `price >= 200000` | 20만원 이상 상품은 몇 건인가 | 1,467 | - | 제거 후 10,000 |
| `in_stock : false` | 재고 없는 상품은 몇 건인가 | 1,531 | P-00019 | 제거 후 10,000 |

세 값 모두 `GET /products/_search` 집계로 확인. 화면 재현 안 함.

## 교시 완료 신호

- GREEN: 필수 1~4 완료, 마지막 상태 20,000, KQL/filter 없음
- YELLOW: 결과는 있으나 수치·시간·field 중 하나가 다름
- RED: Data View 또는 Discover에서 데이터를 확인할 수 없음

**판정: YELLOW**. Data View, field, KQL 동작은 정상. 기준 문서 수만 20,000이 아닌 10,000(교재 버전 차이).
