-- PROPEX.V_FATURAMENTO_NV_BI fonte

CREATE OR REPLACE FORCE VIEW "PROPEX"."V_FATURAMENTO_NV_BI" ("COD_EMPRESA", "RAZAO_SOCIAL", "FANTASIA", "CNPJ_CPF", "COD_NATUREZA_VENDA", "DS_NATUREZA_VENDA", "COD_UNIDADE_NEGOCIO", "DS_UNIDADE_NEGOCIO", "COD_SEGMENTO", "SEGMENTO", "DATA_EMISSAO", "VALOR_TOTAL_NF", "PESO_LIQUIDO_VOLUME", "ANO_EMISSAO", "MES_EMISSAO", "ANOMES_EMISSAO", "SEM_ANO_EMISSAO", "SEM_MES_EMISSAO", "NUMERO_NF", "COD_PEDIDO", "NUMERO_OP", "COD_DESTINATARIO", "DS_CLIENTE", "COD_GRUPO_CLIENTE", "DS_GRUPO", "CDCLI_CIDADE", "DSCLI_CIDADE", "CLI_UF", "MERCADO", "COD_REPRESENTANTE", "DS_REPRESENTANTE", "CDREP_CIDADE", "DSREP_CIDADE", "REP_UF", "COD_PRODUTO", "DESCRICAO_VENDA", "DESCRICAO_PROD", "COD_CFOP", "SEQUENCIA", "VALOR_TOTAL", "PESO", "UNIDADE_PRODUTO", "QUANTIDADE", "QUANTIDADE_UND", "QUANTIDADE_UN_MEDIDA_PRODUTO", "VALOR_UNITARIO", "ICMS", "IPI", "PIS", "COFINS", "DESCONTOS_NFE", "VALOR_LIQUIDO", "UNIDADE_MEDIDA", "TIPO", "COD_TIPO_PRODUTO", "TIPO_PRODUTO", "COD_LINHA_PRODUCAO", "LINHA_PRODUCAO", "COD_SAIDA", "SERIE_NF", "DATA_SAIDA", "DATA_TRANSMISSAO", "MODALIDADE_FRETE", "VALOR_FRETE", "COD_TRANSPORTADORA", "QUANTIDADE_VOLUME", "ESPECIE_VOLUME", "CHAVE_NFE", "COMPLEMENTO", "PERCENTUAL_COMISSAO", "OC_CLIENTE", "SEQ_OC_CLIENTE", "TIPO_MOVIMENTO", "ID_FATURAMENTO", "SITUACAO", "PRECO_MEDIO_BRUTO", "PRECO_MEDIO_LIQUIDO") AS 
  SELECT LFSI.COD_EMPRESA,
          EM.RAZAO_SOCIAL,
          EM.FANTASIA,
          EM.CNPJ_CPF,
          P.COD_NATUREZA_VENDA_PRO,                                       --05
          CASE
             WHEN P.COD_NATUREZA_VENDA_PRO IS NULL THEN 'Residuo'
             ELSE NV.DESCRICAO
          END
             AS DS_NATUREZA_VENDA,
          UN.COD_UNIDADE_NEGOCIO AS COD_UNIDADE_NEGOCIO,
          UN.DESCRICAO AS DS_UNIDADE_NEGOCIO,
          SM.COD_SEGMENTO,
          SM.DESCRICAO SEGMENTO,                                          --10
          TRUNC (LFS.DATA_EMISSAO) AS DATA_EMISSAO,
          LFS.VALOR_TOTAL_NF,
          LFS.PESO_LIQUIDO_VOLUME,
          TO_CHAR (LFS.DATA_EMISSAO, 'YYYY') AS ANO_EMISSAO,
          TO_CHAR (LFS.DATA_EMISSAO, 'MM') AS MES_EMISSAO,                --15
          TO_CHAR (LFS.DATA_EMISSAO, 'YYYY/MM') AS ANOMES_EMISSAO,
          TO_CHAR (LFS.DATA_EMISSAO, 'WW') AS SEM_ANO_EMISSAO,
          TO_CHAR (LFS.DATA_EMISSAO, 'W') AS SEM_MES_EMISSAO,
          LFS.NUMERO_NF,
          LFSI.COD_PEDIDO,                                                --20
          LFSI.NUMERO_OP,
          E.COD_ENTIDADE AS COD_CLIENTE,
          E.RAZAO_SOCIAL AS DS_CLIENTE,
          CASE
             WHEN CL.COD_GRUPO_CLIENTE IS NULL THEN E.COD_ENTIDADE
             ELSE CL.COD_GRUPO_CLIENTE
          END
             AS COD_GRUPO_CLIENTE,
          CASE
             WHEN CL.COD_GRUPO_CLIENTE IS NULL THEN E.RAZAO_SOCIAL
             ELSE CG.NOME
          END
             AS DS_GRUPO,
          E.COD_CIDADE AS CDCLI_CIDADE,                                   --25
          ECID.NOME AS DSCLI_CIDADE,
          E.UNIDADE_FEDERACAO AS CLI_UF,
          CASE WHEN E.UNIDADE_FEDERACAO = 'EX' THEN 'ME' ELSE 'MI' END
             AS MERCADO,
          R.COD_ENTIDADE AS COD_REPRESENTANTE,
          R.RAZAO_SOCIAL AS DS_REPRESENTANTE,
          R.COD_CIDADE AS CDREP_CIDADE,                                   --30
          RCID.NOME AS DSREP_CIDADE,
          R.UNIDADE_FEDERACAO AS REP_UF,
          LFSI.COD_PRODUTO,
          P.DESCRICAO_VENDA,
          P.DESCRICAO AS DESCRICAO_PRODUTO,                               --35
          LFSI.COD_CFOP,
          LFSI.SEQUENCIA,
          (  LFSI.VALOR_TOTAL
           + LFSI.VALOR_ACRESCIMO
           - NVL (
                  LFSI.VALOR_ABATIMENTOS_NTRIB
                + LFSI.VALOR_DESCONTOS
                + LFSI.VALOR_SEGURO
                + NVL (
                     (SELECT SUM (LFSII2.VALOR_ICMS_SUFRAMA)
                        FROM LCTO_FISCAL_SAI_ITENS_IMP LFSII2
                       WHERE     (LFSII2.COD_EMPRESA = LFSI.COD_EMPRESA)
                             AND (LFSII2.COD_SAIDA = LFSI.COD_SAIDA)
                             AND (LFSII2.SEQUENCIA = LFSI.SEQUENCIA)
                             AND (LFSII2.TIPO_IMPOSTO = 1)),
                     0),
                0))
             AS VALOR_TOTAL,                                              --40
          LFSI.PESO,
          P.COD_UNIDADE AS UNIDADE_PRODUTO,
          CASE
             WHEN (LFSI.UNIDADE_MEDIDA = 'UN' AND PA.COD_UNIDADE_NEGOCIO = 1)
             THEN
                (LFSI.QUANTIDADE / 1000)
             ELSE
                (LFSI.QUANTIDADE)
          END
             AS QUANTIDADE,                                               --40
          CASE
             WHEN (LFSI.UNIDADE_MEDIDA = 'ML' AND PA.COD_UNIDADE_NEGOCIO = 1)
             THEN
                (LFSI.QUANTIDADE * 1000)
             ELSE
                (LFSI.QUANTIDADE)
          END
             AS QUANTIDADE_UND,
          CASE
             WHEN E.UNIDADE_FEDERACAO = 'EX'
             THEN
                CASE
                   WHEN P.COD_UNIDADE = 'M2'
                   THEN
                      (SELECT NVL (SUM (METROS_M2), 0)
                         FROM V_ETIQUETAS_LIDA_NFE V
                        WHERE     V.COD_EMPRESA = LFS.COD_EMPRESA
                              AND (V.NUMERO_NF = LFS.NUMERO_NF)
                              AND V.COD_PRODUTO = LFSI.COD_PRODUTO
                              AND V.COD_OP = LFSI.COD_OP)
                   WHEN P.COD_UNIDADE = 'UN'
                   THEN
                      (SELECT NVL (SUM (QUANTIDADE), 0)
                         FROM V_ETIQUETAS_LIDA_NFE V
                        WHERE     V.COD_EMPRESA = LFS.COD_EMPRESA
                              AND (V.NUMERO_NF = LFS.NUMERO_NF)
                              AND V.COD_PRODUTO = LFSI.COD_PRODUTO
                              AND V.COD_OP = LFSI.COD_OP)
                   WHEN P.COD_UNIDADE = 'ML'
                   THEN
                      (SELECT NVL (SUM (QUANTIDADE), 0)
                         FROM V_ETIQUETAS_LIDA_NFE V
                        WHERE     V.COD_EMPRESA = LFS.COD_EMPRESA
                              AND (V.NUMERO_NF = LFS.NUMERO_NF)
                              AND V.COD_PRODUTO = LFSI.COD_PRODUTO
                              AND V.COD_OP = LFSI.COD_OP)
                   ELSE
                      LFSI.QUANTIDADE
                END
             ELSE
                CASE
                   WHEN (    LFSI.UNIDADE_MEDIDA = 'ML'
                         AND PA.COD_UNIDADE_NEGOCIO = 1)
                   THEN
                      (LFSI.QUANTIDADE * 1000)
                   ELSE
                      (LFSI.QUANTIDADE)
                END
          --40


          END
             AS QUANTIDADE_UN_MEDIDA_PRODUTO,
          LFSI.VALOR_UNITARIO,
          RETORNA_SOMA_IMPOSTO_SAIDA (LFS.COD_EMPRESA,
                                      LFS.COD_SAIDA,
                                      LFSI.SEQUENCIA,
                                      1)
             AS ICMS,
          RETORNA_SOMA_IMPOSTO_SAIDA (LFS.COD_EMPRESA,
                                      LFS.COD_SAIDA,
                                      LFSI.SEQUENCIA,
                                      2)
             AS IPI,                                                      --45
          RETORNA_SOMA_IMPOSTO_SAIDA (LFS.COD_EMPRESA,
                                      LFS.COD_SAIDA,
                                      LFSI.SEQUENCIA,
                                      3)
             AS PIS,
          RETORNA_SOMA_IMPOSTO_SAIDA (LFS.COD_EMPRESA,
                                      LFS.COD_SAIDA,
                                      LFSI.SEQUENCIA,
                                      4)
             AS COFINS,
          SOMA_DESCONTOS_NFE_SEM_ICMS (LFS.COD_EMPRESA,
                                       LFS.COD_SAIDA,
                                       LFSI.SEQUENCIA)
             AS DESCONTOS_NFE,
          (  LFSI.VALOR_TOTAL
           + LFSI.VALOR_ACRESCIMO
           - RETORNA_SOMA_DESCONTOS_NFE (LFS.COD_EMPRESA,
                                         LFS.COD_SAIDA,
                                         LFSI.SEQUENCIA))
             AS VALOR_LIQUIDO,
          LFSI.UNIDADE_MEDIDA,                                            --60
          CASE
             WHEN                                          --SACARIA SEM LINER
                  (   NV.COD_UNIDADE_NEGOCIO_PRIMARIO = 1)
                  AND (NV.COD_UNIDADE_NEGOCIO_SECUNDARIO IS NULL)
             THEN
                'SACARIA SEM LINER'
             WHEN                                          --SACARIA COM LINER
                  (   NV.COD_UNIDADE_NEGOCIO_PRIMARIO = 1)
                  AND (NV.COD_UNIDADE_NEGOCIO_SECUNDARIO IS NOT NULL)
             THEN
                'SACARIA COM LINER'
             WHEN                                          --BIG BAG SEM LINER
                  (   NV.COD_UNIDADE_NEGOCIO_PRIMARIO = 2)
                  AND (NV.COD_UNIDADE_NEGOCIO_SECUNDARIO IS NULL)
             THEN
                'BIG BAG SEM LINER'
             WHEN                                          --BIG BAG COM LINER
                  (   NV.COD_UNIDADE_NEGOCIO_PRIMARIO = 2)
                  AND (NV.COD_UNIDADE_NEGOCIO_SECUNDARIO IS NOT NULL)
             THEN
                'BIG BAG COM LINER'
             WHEN                                                     --TECIDO
                  (   NV.COD_UNIDADE_NEGOCIO_PRIMARIO = 4)
                  AND (NV.COD_UNIDADE_NEGOCIO_SECUNDARIO IS NULL)
             THEN
                'TECIDO'
             WHEN                                                      --LINER
                  (   NV.COD_UNIDADE_NEGOCIO_PRIMARIO = 3)
                  AND (NV.COD_UNIDADE_NEGOCIO_SECUNDARIO IS NULL)
             THEN
                'LINER'
             WHEN                                                     --CLICHE
                  (   NV.COD_UNIDADE_NEGOCIO_PRIMARIO = 25)
                  AND (NV.COD_UNIDADE_NEGOCIO_SECUNDARIO IS NULL)
             THEN
                'CLICHE'
             WHEN                                                     --OUTRAS
                  (       (NV.COD_UNIDADE_NEGOCIO_PRIMARIO <> 1)
                      AND (NV.COD_UNIDADE_NEGOCIO_PRIMARIO <> 2)
                      AND (NV.COD_UNIDADE_NEGOCIO_PRIMARIO <> 3)
                      AND (NV.COD_UNIDADE_NEGOCIO_PRIMARIO <> 4))
                  AND (NV.COD_UNIDADE_NEGOCIO_SECUNDARIO IS NULL)
             THEN
                'OUTRAS'
             ELSE
                'NAO DEFINIDO'
          END
             AS TIPO,
          P.COD_TIPO_PRODUTO_PRO,
          TP.DESCRICAO AS TIPO_PRODUTO,
          PA.COD_LINHA_PRODUCAO,
          (CASE
              WHEN PA.COD_UNIDADE_NEGOCIO = 2
              THEN
                 LP.NOME
              WHEN PA.COD_UNIDADE_NEGOCIO = 1
              THEN
                 (SELECT TRIM (VFS.TIPO_SACARIA)
                    FROM FICHA_PRODUTO_SACARIA VFS
                   WHERE     VFS.COD_PRODUTO = PA.COD_PRODUTO
                         AND VFS.REVISAO =
                                (SELECT MAX (VFSS.REVISAO)
                                   FROM FICHA_PRODUTO_SACARIA VFSS
                                  WHERE VFSS.COD_PRODUTO = PA.COD_PRODUTO))
              WHEN PA.COD_UNIDADE_NEGOCIO = 4
              THEN
                 'TECIDO'
              ELSE
                 'OUTROS'
           END)
             AS LINHA_PRODUCAO,
          LFS.COD_SAIDA,
          LFS.SERIE_NF,
          LFS.DATA_SAIDA,
          LFS.DATA_TRANSMISSAO,
          LFS.MODALIDADE_FRETE,
          BUSCA_VALOR_FRETE_ITEM_CF_BI (LFS.COD_SAIDA,
                                        LFSI.SEQUENCIA,
                                        'SAIDA',
                                        LFS.COD_EMPRESA,
                                        LFS.VALOR_TOTAL_NF)
             AS VALOR_FRETE,
          LFS.COD_TRANSPORTADORA,
          LFS.QUANTIDADE_VOLUME,
          LFS.ESPECIE_VOLUME,
          LFS.CHAVE_NFE,
          LFS.COMPLEMENTO,
          LFSI.PERCENTUAL_COMISSAO,
          LFSI.OC_CLIENTE,
          LFSI.SEQ_OC_CLIENTE,
          'S' AS TIPO_MOVIMENTO,
          LFSI.ID_FATURAMENTO,
          LFS.SITUACAO,
          CASE
             WHEN LFSI.PESO <> 0 THEN ROUND ( (VALOR_TOTAL / LFSI.PESO), 2)
          END
             AS PRECO_MEDIO_BRUTO,
          CASE
             WHEN LFSI.PESO <> 0
             THEN
                ROUND (
                   (  (  LFSI.VALOR_TOTAL
                       + LFSI.VALOR_ACRESCIMO
                       - RETORNA_SOMA_DESCONTOS_NFE (LFS.COD_EMPRESA,
                                                     LFS.COD_SAIDA,
                                                     LFSI.SEQUENCIA))
                    / LFSI.PESO),
                   2)
          END
             AS PRECO_MEDIO_LIQUIDO
     FROM LCTO_FISCAL_SAI LFS
          LEFT JOIN
          LCTO_FISCAL_SAI_ITENS LFSI
             ON     LFSI.COD_SAIDA = LFS.COD_SAIDA
                AND LFS.COD_EMPRESA = LFSI.COD_EMPRESA
          LEFT JOIN ENTIDADES E ON E.COD_ENTIDADE = LFS.COD_DESTINATARIO
          LEFT JOIN CLIENTES CL ON E.COD_ENTIDADE = CL.COD_ENTIDADE
          LEFT JOIN CLIENTES_GRUPOS CG ON CL.COD_GRUPO_CLIENTE = CG.COD_GRUPO
          LEFT JOIN CIDADES ECID ON E.COD_CIDADE = ECID.COD_CIDADE
          LEFT JOIN ENTIDADES R ON R.COD_ENTIDADE = LFS.COD_REPRESENTANTE
          LEFT JOIN CIDADES RCID ON R.COD_CIDADE = RCID.COD_CIDADE
          LEFT JOIN PRODUTOS P ON P.COD_PRODUTO = LFSI.COD_PRODUTO
          LEFT JOIN PRODUTOS_ACABADOS PA ON PA.COD_PRODUTO = LFSI.COD_PRODUTO
          LEFT JOIN LINHAS_PRODUCAO LP
             ON LP.COD_LINHA = PA.COD_LINHA_PRODUCAO
          LEFT JOIN UNIDADES_NEGOCIO UN
             ON UN.COD_UNIDADE_NEGOCIO = P.COD_UN_NEGOCIO_GRUPO
          LEFT JOIN NATUREZAS_VENDA NV
             ON NV.COD_NATUREZA_VENDA = P.COD_NATUREZA_VENDA_PRO
          LEFT JOIN SEGMENTOS_MERCADO SM ON SM.COD_SEGMENTO = P.COD_SEGMENTO
          LEFT JOIN TIPOS_PRODUTOS TP
             ON TP.COD_TIPO_PRODUTO = P.COD_TIPO_PRODUTO_PRO
          LEFT JOIN EMPRESA EM ON LFSI.COD_EMPRESA = EM.COD_EMPRESA
          LEFT JOIN
          TIPO_MOVIMENTO_FISCAL TMF
             ON     TMF.COD_TIPO_MOVIMENTO = LFS.COD_TIPO_MOVIMENTO
                AND LFS.COD_EMPRESA = TMF.COD_EMPRESA
          LEFT JOIN
          CFOP CF
             ON     LFSI.COD_EMPRESA = CF.COD_EMPRESA
                AND LFSI.COD_CFOP = CF.COD_CFOP
    WHERE     (TMF.ID_TIPO_MOVIMENTO = 'S')
          AND (LFS.SITUACAO <> 'C')
          AND (TRUNC (LFS.DATA_EMISSAO) > TRUNC (TO_DATE ('01/01/2021')))
   UNION
   SELECT LFEI.COD_EMPRESA,                                                --1
          EM.RAZAO_SOCIAL,                                                 --2
          EM.FANTASIA,                                                     --3
          EM.CNPJ_CPF,                                                     --4
          P.COD_NATUREZA_VENDA_PRO AS COD_NATUREZA_VENDA,                  --5
          NV.DESCRICAO AS DS_NATUREZA_VENDA,                               --6
          P.COD_UN_NEGOCIO_PRO AS COD_UNIDADE_NEGOCIO,                     --7
          UN.DESCRICAO AS DS_UNIDADE_NEGOCIO,                              --8
          SM.COD_SEGMENTO,
          SM.DESCRICAO SEGMENTO,
          TRUNC (LFE.DATA_ENTRADA) AS DATA_EMISSAO,                        --9
          0 AS VALOR_TOTAL_NF,                                            --10
          0 AS PESO_LIQUIDO_VOLUME,                                       --11
          TO_CHAR (LFE.DATA_ENTRADA, 'YYYY') AS ANO_EMISSAO,              --12
          TO_CHAR (LFE.DATA_ENTRADA, 'MM') AS MES_EMISSAO,                --13
          TO_CHAR (LFE.DATA_ENTRADA, 'YYYY/MM') AS ANOMES_EMISSAO,        --14
          TO_CHAR (LFE.DATA_ENTRADA, 'WW') AS SEM_ANO_EMISSAO,            --15
          TO_CHAR (LFE.DATA_ENTRADA, 'W') AS SEM_MES_EMISSAO,             --16
          LFE.NUMERO_NF,                                                  --17
          0 AS COD_PEDIDO,                                                --18
          '0' AS NUMERO_OP,                                               --19
          E.COD_ENTIDADE AS COD_CLIENTE,                                  --20
          E.RAZAO_SOCIAL AS DS_CLIENTE,                                   --21
          0 AS COD_GRUPO_CLIENTE,                                         --22
          '' AS DS_GRUPO,                                                 --23
          E.COD_CIDADE AS CDCLI_CIDADE,                                   --24
          '' AS DSCLI_CIDADE,                                             --25
          E.UNIDADE_FEDERACAO AS CLI_UF,                                  --26
          CASE WHEN E.UNIDADE_FEDERACAO = 'EX' THEN 'ME' ELSE 'MI' END
             AS MERCADO,
          CLI.COD_REPRESENTANTE AS COD_REPRESENTANTE,                     --27
          REP.RAZAO_SOCIAL AS DS_REPRESENTANTE,                           --28
          0 AS CDREP_CIDADE,                                              --29
          '' AS DSREP_CIDADE,                                             --30
          '' AS REP_UF,                                                   --31
          LFEI.COD_PRODUTO,                                               --32
          P.DESCRICAO_VENDA,                                              --33
          P.DESCRICAO AS DESCRICAO_PRODUTO,                               --34
          LFEI.COD_CFOP,                                                  --35
          LFEI.SEQUENCIA,                                                 --36
          (  -1
           * (  LFEI.VALOR_TOTAL
              + NVL (LFEI.VALOR_ACRESCIMO, 0)
              - (  NVL (LFEI.VALOR_ABATIMENTOS_NTRIB, 0)
                 + NVL (LFEI.VALOR_SEGURO, 0)
                 + NVL (LFEI.VALOR_DESCONTOS, 0))))
             AS VALOR_TOTAL,                                              --37
          (-1 * LFEI.PESO) AS PESO,
          P.COD_UNIDADE AS UNIDADE_PRODUTO,                               --38
          CASE
             WHEN (LFEI.UNIDADE_MEDIDA = 'UN' AND PA.COD_UNIDADE_NEGOCIO = 1)
             THEN
                (-1 * (LFEI.QUANTIDADE / 1000))
             ELSE
                (-1 * (LFEI.QUANTIDADE))
          END
             AS QUANTIDADE,                                               --39
          CASE
             WHEN (LFEI.UNIDADE_MEDIDA <> 'UN' AND PA.COD_UNIDADE_NEGOCIO = 1)
             THEN
                (-1 * (LFEI.QUANTIDADE * 1000))
             ELSE
                (-1 * (LFEI.QUANTIDADE))
          END
             AS QUANTIDADE_UND,
          CASE
             WHEN (LFEI.UNIDADE_MEDIDA <> 'UN' AND PA.COD_UNIDADE_NEGOCIO = 1)
             THEN
                (-1 * (LFEI.QUANTIDADE * 1000))
             ELSE
                (-1 * (LFEI.QUANTIDADE))
          END
             AS QUANTIDADE_UN_MEDIDA_PRODUTO,                             --40
          LFEI.VALOR_UNITARIO,                                            --41
          0 AS ICMS,                                                      --42
          0 AS IPI,                                                       --43
          0 AS PIS,                                                       --44
          0 AS COFINS,                                                    --45
          0 AS DESCONTOS_NFE,                                             --46
          (  -1
           * (  LFEI.VALOR_TOTAL
              + NVL (LFEI.VALOR_ACRESCIMO, 0)
              - (  NVL (
                        NVL (LFEI.VALOR_ABATIMENTOS_NTRIB, 0)
                      + NVL (LFEI.VALOR_DESCONTOS, 0)
                      + NVL (LFEI.VALOR_SEGURO, 0),
                      0)
                 + RETURN_SUM_PIS_CONF_ICMS_SQ_DV (LFEI.COD_EMPRESA,
                                                   LFEI.COD_ENTRADA,
                                                   LFEI.SEQUENCIA))))
             AS VALOR_LIQUIDO,                                            --47
          LFEI.UNIDADE_MEDIDA,                                            --48
          CASE
             WHEN                                          --SACARIA SEM LINER
                  (   NV.COD_UNIDADE_NEGOCIO_PRIMARIO = 1)
                  AND (NV.COD_UNIDADE_NEGOCIO_SECUNDARIO IS NULL)
             THEN
                'SACARIA SEM LINER'
             WHEN                                          --SACARIA COM LINER
                  (   NV.COD_UNIDADE_NEGOCIO_PRIMARIO = 1)
                  AND (NV.COD_UNIDADE_NEGOCIO_SECUNDARIO IS NOT NULL)
             THEN
                'SACARIA COM LINER'
             WHEN                                          --BIG BAG SEM LINER
                  (   NV.COD_UNIDADE_NEGOCIO_PRIMARIO = 2)
                  AND (NV.COD_UNIDADE_NEGOCIO_SECUNDARIO IS NULL)
             THEN
                'BIG BAG SEM LINER'
             WHEN                                          --BIG BAG COM LINER
                  (   NV.COD_UNIDADE_NEGOCIO_PRIMARIO = 2)
                  AND (NV.COD_UNIDADE_NEGOCIO_SECUNDARIO IS NOT NULL)
             THEN
                'BIG BAG COM LINER'
             WHEN                                                     --TECIDO
                  (   NV.COD_UNIDADE_NEGOCIO_PRIMARIO = 4)
                  AND (NV.COD_UNIDADE_NEGOCIO_SECUNDARIO IS NULL)
             THEN
                'TECIDO'
             WHEN                                                      --LINER
                  (   NV.COD_UNIDADE_NEGOCIO_PRIMARIO = 3)
                  AND (NV.COD_UNIDADE_NEGOCIO_SECUNDARIO IS NULL)
             THEN
                'LINER'
             WHEN                                                     --CLICHE
                  (   NV.COD_UNIDADE_NEGOCIO_PRIMARIO = 25)
                  AND (NV.COD_UNIDADE_NEGOCIO_SECUNDARIO IS NULL)
             THEN
                'CLICHE'
             WHEN                                                     --OUTRAS
                  (       (NV.COD_UNIDADE_NEGOCIO_PRIMARIO <> 1)
                      AND (NV.COD_UNIDADE_NEGOCIO_PRIMARIO <> 2)
                      AND (NV.COD_UNIDADE_NEGOCIO_PRIMARIO <> 3)
                      AND (NV.COD_UNIDADE_NEGOCIO_PRIMARIO <> 4))
                  AND (NV.COD_UNIDADE_NEGOCIO_SECUNDARIO IS NULL)
             THEN
                'OUTRAS'
             ELSE
                'NAO DEFINIDO'
          END
             AS TIPO,                                                     --49
          PA.COD_TIPO_PRODUTO,                                            --50
          '' AS TIPO_PRODUTO,                                             --51
          PA.COD_LINHA_PRODUCAO,                                          --52
          '' AS LINHA_PRODUCAO,                                           --53
          0 AS COD_SAIDA, -- NFS.COD_SAIDA, --LFER.COD_SAIDA_REF AS COD_SAIDA,                --54
          '' AS SERIE_NF, --NFS.SERIE_NF,                                                   --55
          NULL AS DATA_SAIDA, --NFS.DATA_SAIDA,                                                 --56
          NULL AS DATA_TRANSMISSAO, --NFS.DATA_TRANSMISSAO,                                           --57
          '' AS MODALIDADE_FRETE,                                         --58
          --          0 AS VALOR_FRETE,                                               --59
          BUSCA_VALOR_FRETE_ITEM_CF (LFEI.COD_ENTRADA,
                                     LFEI.SEQUENCIA,
                                     'ENTRADA',
                                     LFEI.COD_EMPRESA,
                                     LFE.VALOR_TOTAL_NF)
             AS VALOR_FRETE,
          0 AS COD_TRANSPORTADORA,                                        --60
          0 AS QUANTIDADE_VOLUME,                                         --61
          '' AS ESPECIE_VOLUME,                                           --62
          '' AS CHAVE_NFE,                                                --63
          '' AS COMPLEMENTO,                                              --64
          BUSCA_COMISSAO_NOTA_SAIDA (LFE.COD_EMPRESA, LFE.COD_ENTRADA)
             AS PERCENTUAL_COMISSAO,                                      --65
          '' AS OC_CLIENTE,                                               --66
          0 AS SEQ_OC_CLIENTE,                                            --67
          'S' AS TIPO_MOVIMENTO,                                          --68
          LFEI.ID_FATURAMENTO,                                            --69
          'M' AS SITUACAO,  --NFS.SITUACAO,                               --70
          CASE
             WHEN LFEI.PESO <> 0
             THEN
                ROUND (-1 * (VALOR_TOTAL / LFEI.PESO), 2)
             ELSE
                0
          END
             AS PRECO_MEDIO_BRUTO,                                        --71
          CASE
             WHEN LFEI.PESO <> 0
             THEN
                ROUND (
                   (  (  -1
                       * (  LFEI.VALOR_TOTAL
                          + NVL (LFEI.VALOR_ACRESCIMO, 0)
                          - (  NVL (
                                    NVL (LFEI.VALOR_ABATIMENTOS_NTRIB, 0)
                                  + NVL (LFEI.VALOR_DESCONTOS, 0)
                                  + NVL (LFEI.VALOR_SEGURO, 0),
                                  0)
                             + RETURN_SUM_PIS_CONF_ICMS_SQ_DV (
                                  LFEI.COD_EMPRESA,
                                  LFEI.COD_ENTRADA,
                                  LFEI.SEQUENCIA))))
                    / LFEI.PESO),
                   2)
             ELSE
                0
          END
             AS PRECO_MEDIO_LIQUIDO
     FROM LCTO_FISCAL_ENT LFE
          --          LEFT JOIN
          --          LCTO_FISCAL_ENT_REF_SAI LFER
          --             ON     LFE.COD_EMPRESA = LFER.COD_EMPRESA
          --                AND LFE.COD_ENTRADA = LFER.COD_ENTRADA
          LEFT JOIN
          LCTO_FISCAL_ENT_ITENS LFEI
             ON     LFE.COD_ENTRADA = LFEI.COD_ENTRADA
                AND LFE.COD_EMPRESA = LFEI.COD_EMPRESA
          --          LEFT JOIN
          --          LCTO_FISCAL_SAI NFS
          --             ON     LFE.COD_EMPRESA = NFS.COD_EMPRESA
          --                AND LFER.COD_SAIDA_REF = NFS.COD_SAIDA
          --          LEFT JOIN
          --          LCTO_FISCAL_SAI_ITENS NFSI
          --             ON     LFE.COD_EMPRESA = NFSI.COD_EMPRESA
          --                AND LFER.COD_SAIDA_REF = NFSI.COD_SAIDA
          -- LEFT JOIN LCTO_FISCAL_SAI_ITENS LFSI ON LFSI.COD_SAIDA = LFER.COD_SAIDA_REF AND LFSI.COD_EMPRESA = LFE.COD_EMPRESA
          --                                    AND LFSI.COD_PRODUTO=LFEI.COD_PRODUTO AND LFEI.VALOR_TOTAL=LFSI.VALOR_TOTAL
          LEFT JOIN ENTIDADES E ON E.COD_ENTIDADE = LFE.COD_ENTIDADE --NFS.COD_DESTINATARIO
          LEFT JOIN CLIENTES CLI ON E.COD_ENTIDADE = CLI.COD_ENTIDADE
          LEFT JOIN ENTIDADES REP ON CLI.COD_REPRESENTANTE = REP.COD_ENTIDADE
          -- LEFT JOIN ORDENS_PRODUCAO OP ON LFSI.COD_OP = OP.COD_OP
          LEFT JOIN PRODUTOS_ACABADOS PA ON LFEI.COD_PRODUTO = PA.COD_PRODUTO
          LEFT JOIN PRODUTOS P ON LFEI.COD_PRODUTO = P.COD_PRODUTO
          LEFT JOIN
          TIPO_MOVIMENTO_FISCAL TMS
             ON     LFE.COD_EMPRESA = TMS.COD_EMPRESA
                AND LFE.COD_TIPO_MOVIMENTO = TMS.COD_TIPO_MOVIMENTO
          LEFT JOIN NATUREZAS_VENDA NV
             ON NV.COD_NATUREZA_VENDA = P.COD_NATUREZA_VENDA_PRO
          LEFT JOIN
          CFOP CF
             ON     LFEI.COD_EMPRESA = CF.COD_EMPRESA
                AND LFEI.COD_CFOP = CF.COD_CFOP
          LEFT JOIN EMPRESA EM ON LFEI.COD_EMPRESA = EM.COD_EMPRESA
          LEFT JOIN UNIDADES_NEGOCIO UN
             ON UN.COD_UNIDADE_NEGOCIO = P.COD_UN_NEGOCIO_PRO
          LEFT JOIN SEGMENTOS_MERCADO SM ON SM.COD_SEGMENTO = P.COD_SEGMENTO
          LEFT JOIN TIPOS_PRODUTOS TP
             ON TP.COD_TIPO_PRODUTO = P.COD_TIPO_PRODUTO_PRO
    WHERE     (LFEI.ID_FATURAMENTO = 'S')
          --AND LFE.COD_ENTIDADE NOT IN (2964, 2401, 12925, 3) retirado conforme chamado 2475 glpi
          --AND LFEI.VALOR_TOTAL <> 0
          AND LFE.DATA_ENTRADA > TO_DATE ('01/01/2023');

GRANT SELECT ON "PROPEX"."V_FATURAMENTO_NV_BI" TO "BI_FULL";
