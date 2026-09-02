# Day 1 환경 확인 기록

- 확인 일시: 2026-08-31 14:30
- 실행 위치: Kibana Dev Tools Console (`http://localhost:5601/app/dev_tools#/console/shell`)
- 실행 요청 파일: `elasticsearch/requests.http`

## 1. Docker 상태

Elasticsearch node 3개(es01, es02, es03)와 Kibana 컨테이너가 실행 중이다.
setup 컨테이너는 인증서 생성을 마치고 정상 종료(exit 0)했다.

- 판정: 통과

## 2. Kibana 접속

`http://localhost:5601` 로그인 성공, Dev Tools Console 화면을 열었다.

- 판정: 통과

## 3. `GET /`

| 확인 항목 | 출력 값 |
|---|---|
| version number | `9.5.0` |
| cluster_name | `es-5days-pbl` |
| lucene_version | `10.5.0` |

교재가 지정한 9.5.0과 일치한다.

- 판정: 통과

## 4. `GET /_cluster/health`

| 확인 항목 | 출력 값 |
|---|---|
| status | `green` |
| number_of_nodes | `3` |
| unassigned_shards | `0` |

`green`은 primary와 replica shard가 모두 배정됐다는 뜻이다. node가 3개라 replica가 다른 node에 배치될 수 있었다.

- 판정: 통과

## 5. `GET /_cat/nodes?v`

es01, es02, es03 세 줄이 표시되고 es03이 마스터(`*`)로 선출됐다.

- 판정: 통과

## 종합 판정

성공 기준 3개(ES 9.5.0 / cluster green / node 3개)를 모두 충족했다. Day 1 환경 구축 완료.

> 비밀번호, `.env` 실제 값, 토큰은 기록하지 않는다.
