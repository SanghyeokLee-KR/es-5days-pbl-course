# 6교시 실습 — 정렬·highlight

## (공통) 문제 1 — 제공 코드로 1·2차 정렬 확인

```http
GET /products/_search
{
  "size": 10,
  "_source": ["product_id", "name", "price", "rating", "in_stock"],
  "query": { "match": { "name": "무선" } },
  "sort": [
    { "rating": "desc" },
    { "price": "asc" }
  ]
}
```

### 결과 입력

- 상위 5개 ID / rating / price: P-03842(5.0/13900), P-08761(5.0/107200), P-07634(5.0/132300), P-05962, P-06457
- 1차 정렬이 올바른가: 예 — rating 5.0(만점)인 문서들이 최상위에 몰려 있다.
- rating 동률에서 2차 정렬이 적용된 사례: 있음 — 상위 3개가 전부 rating=5.0으로 동률인데 price가 13900 → 107200 → 132300원으로 오름차순 정렬돼 2차 정렬이 정확히 작동함을 확인했다.
- 동률이 없다면 2차 정렬을 확인할 수 있는 방법: (해당 없음 — 실제 동률 사례를 확인했다) 동률이 없었다면 `term`으로 같은 rating 값을 가진 문서만 미리 추려서 그 부분집합으로 정렬을 재실행하면 된다.

## (공통) 문제 2 — 정렬 우선순위 교환

문제 1과 같은 검색 결과를 가격이 낮은 순서로 먼저 정렬하고, 가격이 같으면 평점이 높은 순서로 정렬하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "_source": ["product_id", "name", "price", "rating", "in_stock"],
  "query": { "match": { "name": "무선" } },
  "sort": [
    { "price": "asc" },
    { "rating": "desc" }
  ]
}
```

### 비교 결과

- 변경 후 상위 5개 ID / price / rating: P-01490(10900원/2.9), P-05738, P-05218, P-08586, P-03842
- 순서가 달라진 문서: 상위 5개가 문제 1과 거의 다르다 — 정렬 방향을 바꾸니 최상위 후보군 자체가 저가 상품 위주로 바뀌었다.
- 검색 hit 집합도 달라졌는가: 아니다. `hits.total.value`는 두 요청 모두 505로 동일하다. `query`는 그대로고 `sort`만 바꿨기 때문에 대상 문서 집합은 같고 순서만 바뀐다.

## (공통) 문제 3 — highlight와 표시 field 구현

`name`, `description`에서 `무선 이어폰`을 검색하되 `name`에 3배 boost를 적용하세요. 최대 5건을 반환하고 결과 카드용 field만 `_source`에 포함하며 `name`, `description`에 highlight를 적용하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 5,
  "_source": ["product_id", "name", "description", "price", "rating", "in_stock"],
  "query": {
    "multi_match": {
      "query": "무선 이어폰",
      "fields": ["name^3", "description"]
    }
  },
  "highlight": {
    "fields": {
      "name": {},
      "description": { "fragment_size": 120, "number_of_fragments": 2 }
    }
  }
}
```

### 결과 입력

- `_source` field 목록: `product_id`, `name`, `description`, `price`, `rating`, `in_stock`
- highlight가 생성된 문서 ID와 field: P-00241, P-00305, P-00529, P-00617, P-00777 — 전부 `name` field에 highlight 생성됨(예: "SoundLab 프리미엄 <em>무선</em> <em>이어폰</em>")
- `_source`와 highlight의 차이: `_source`는 원본 그대로의 field 값이고, highlight는 검색어와 일치한 부분에 `<em>` 태그가 씌워진 조각이다.
- highlight가 없는 hit가 있다면 이유 추정: 이번 5건은 전부 `name`에서 highlight가 생성됐다. `description`에는 "무선"·"이어폰"이라는 단어가 직접 등장하지 않는 일반 설명문이라 `description` highlight는 생성되지 않았을 가능성이 있다.

## (개인) 문제 4 — 자기 결과 정렬·카드 설계

자기 서비스에서 중요한 1차·2차 정렬 기준과 결과 카드 field 3~5개를 선택해 Search API를 구현하세요.

### 역할·검증 기준

- 정렬 가능한 mapping type을 사용합니다.
- 1차·2차 정렬의 업무적 이유를 설명합니다.
- 실제 상위 5개 값으로 순서를 검증합니다.

### API와 결과 입력

```http
GET /shop-logs/_search
{
  "size": 10,
  "_source": ["log_id", "service_name", "log_level", "duration_ms", "timestamp"],
  "query": { "match": { "message": "시간" } },
  "sort": [
    { "duration_ms": "desc" },
    { "timestamp": "asc" }
  ]
}
```

- 정렬 field·방향·이유: 1차 `duration_ms desc`(가장 오래 걸린 요청부터 봐야 장애 우선순위를 정할 수 있음), 2차 `timestamp asc`(같은 지연 시간이면 먼저 발생한 것부터)
- 카드 field와 이유: `log_id`(식별), `service_name`(어디서), `log_level`(심각도), `duration_ms`(정렬 기준값 자체를 보여줘야 함)
- 상위 5개 정렬 검증: `duration_ms` 내림차순으로 정렬된 상위 5건(LOG-000353, LOG-000442, LOG-000774, LOG-000910, LOG-000298)을 확인했다.

## (개인) 문제 5 — 자기 highlight 또는 표시 최적화

자기 text 검색에 highlight를 적용하세요. text 검색이 없는 프로젝트라면 `_source` 최소화 전후를 비교하세요.

### 역할·검증 기준

- 검색 field와 highlight field의 관계가 타당해야 합니다.
- 원본 데이터와 강조 조각을 구분합니다.
- 사용자 판단에 실제로 도움이 되는지 평가합니다.

### API와 결과 입력

```http
GET /shop-logs/_search
{
  "size": 5,
  "_source": ["log_id", "service_name", "log_level"],
  "query": { "match": { "message": "시간 초과" } },
  "highlight": { "fields": { "message": {} } }
}
```

- 선택한 방식과 이유: highlight — 운영자가 검색어가 로그 본문 어디에 걸렸는지 한눈에 봐야 하므로
- 실제 결과: LOG-000002, LOG-000016, LOG-000036, LOG-000061, LOG-000071에서 "<em>시간</em> 초과되었습니다." highlight 확인
- 사용자에게 유용한가: 그렇다. `_source`에서 `message`를 뺐어도 highlight로 검색어 주변 문맥을 볼 수 있어 카드가 가벼워지면서도 판단 정보는 유지된다.
- 개선할 점: `products` 예제와 달리 highlight가 "시간"만 강조하고 "초과"는 강조하지 못한다(3교시에서 확인한 토큰 분리 문제와 동일 원인). `nori` 적용이나 검색어 처리 개선이 필요하다.
