# 4교시 실습 — 정확 조건과 경계

## (공통) 문제 1 — 제공 코드로 세 filter 확인

```http
GET /products/_search
{
  "size": 10,
  "query": {
    "bool": {
      "filter": [
        { "term": { "category": "전자기기" } },
        { "term": { "in_stock": true } },
        { "range": { "price": { "gte": 50000, "lte": 200000 } } }
      ]
    }
  }
}
```

### 결과 입력

- `hits.total.value`: 380
- 확인한 문서 ID 3개: P-00025, P-00129, P-00185
- 각 문서의 category / in_stock / price: 세 문서 모두 category는 전자기기, in_stock은 true였고 가격도 50,000원 이상 200,000원 이하에 들어왔다. P-00025의 가격은 59,400원이었다.
- 조건을 위반한 문서가 있는가: 없음

## (공통) 문제 2 — 경계 포함 범위 직접 구현

`products`에서 category가 `전자기기`이고 가격이 50,000원 이상 200,000원 이하인 상품을 검색하세요. 최대 10건을 반환하고 `product_id`, `name`, `category`, `price`만 표시하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "_source": ["product_id", "name", "category", "price"],
  "query": {
    "bool": {
      "filter": [
        { "term": { "category": "전자기기" } },
        { "range": { "price": { "gte": 50000, "lte": 200000 } } }
      ]
    }
  }
}
```

### 결과 입력

- `hits.total.value`: 440
- 최소·최대 price: 반환된 상위 10개 문서를 기준으로 확인했다. 별도의 stats 조회는 하지 않았다.
- 50,000 또는 200,000 경계 문서 존재 여부와 ID: 문제 3의 경계 제외 결과와 비교해서 확인했다. 아래 비교 결과를 참고한다.

## (공통) 문제 3 — 경계 제외 범위 직접 구현

문제 2에서 다른 조건은 모두 그대로 유지하고 가격 조건만 50,000원 초과 200,000원 미만으로 바꾸세요. 한 요소만 변경해야 합니다.

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "_source": ["product_id", "name", "category", "price"],
  "query": {
    "bool": {
      "filter": [
        { "term": { "category": "전자기기" } },
        { "range": { "price": { "gt": 50000, "lt": 200000 } } }
      ]
    }
  }
}
```

### 비교 결과

- 문제 2 total / 문제 3 total: 440 / 440
- 빠진 경계 문서 ID: 없음. 두 요청의 결과가 같았다.
- 경계 문서가 없어 결과가 같다면 확인한 근거: 두 요청 모두 total이 440이었고, 상위 10개 ID(P-00025, P-00129, P-00185...)도 같았다. 전자기기 중에는 가격이 정확히 50,000원이나 200,000원인 문서가 없는 것으로 확인했다.

## (개인) 문제 4 — 자기 정확 조건 2개

자기 데이터에서 정확 조건으로 사용할 field 2개를 선택해 두 조건을 모두 만족하는 검색을 구현하세요.

### 역할·검증 기준

- keyword·boolean 등 실제 mapping type에 적합해야 합니다.
- 실행 전 포함 예상 문서 1개와 제외 예상 문서 1개를 정합니다.
- 실행 후 `_source`로 판정합니다.

### API와 결과 입력

```http
GET /shop-logs/_search
{
  "size": 10,
  "query": {
    "bool": {
      "filter": [
        { "term": { "service_name": "payment-api" } },
        { "term": { "log_level": "ERROR" } }
      ]
    }
  }
}
```

- field·type·값 2개: `service_name`(keyword)=`payment-api`, `log_level`(keyword)=`ERROR`
- 기대 ID / 제외 ID: LOG-000002는 payment-api의 ERROR 로그라 포함될 것으로 예상했다. LOG-000001은 order-api 로그이므로 제외될 것으로 예상했다.
- 실제 결과와 판정: `hits.total.value`는 20이었고 LOG-000002가 상위 결과에 포함된 것을 확인했다. 통과.

## (개인) 문제 5 — 자기 범위와 경계 실험

자기 데이터의 numeric 또는 date field를 선택해 포함 경계와 제외 경계 요청을 각각 구현하세요.

### 역할·검증 기준

- 실제 데이터의 최소·최대 또는 의미 있는 경계값을 먼저 확인합니다.
- `gte/lte`와 `gt/lt` 외 조건은 동일하게 유지합니다.
- 경계 문서가 없으면 fixture 설계 또는 부재 근거를 기록합니다.

### API와 결과 입력

```http
GET /shop-logs/_search
{ "size": 5, "query": { "range": { "duration_ms": { "gte": 50 } } } }
```

```http
GET /shop-logs/_search
{ "size": 5, "query": { "range": { "duration_ms": { "gt": 50 } } } }
```

- field / type / 경계값: `duration_ms` / `integer` / 50. 실제 데이터의 최솟값이며 `evidence/day-02-data.md`의 stats에서 확인했다.
- 포함 요청 total / 제외 요청 total: `gte 50` → 1000 / `gt 50` → 999
- 달라진 문서 ID: 두 결과는 정확히 1건 차이가 났다. `duration_ms`가 50인 LOG-000550이 `gt` 조건에서 빠졌다.
- 경계 판정: 경계값 포함 여부에 따른 차이를 확인했다. 공통 문제에서는 가격이 경계값과 정확히 같은 문서가 없었지만, 이번에는 실제 최솟값을 기준으로 잡아서 `gte`와 `gt`의 차이가 1건으로 나타났다.
