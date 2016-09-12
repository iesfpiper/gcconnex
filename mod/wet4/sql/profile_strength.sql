DROP PROCEDURE IF EXISTS GET_Completness;
CREATE PROCEDURE `GET_Completness`(IN `UserGUID` BIGINT(20), OUT `total` INT, OUT `SkillsPerc` INT, OUT `BasicProfPerc` INT, OUT `AboutPerc` INT, OUT `EduPerc` INT, OUT `WorkPerc` INT, OUT `AvatarPerc` INT) BEGIN declare SkillsTotalMin INT; declare BasicProfTotal INT; declare AvatarTotal INT; declare WorkTotal INT; declare EduTotal INT; declare vTitle INT; declare vDeptarment INT; declare vLocation INT; declare vPhone INT; declare vMobile INT; declare vWeb INT; declare vWork INT; declare vEductation INT; declare vAvatar INT; declare vAboutMe INT; declare Org varchar(255); declare ST varchar(4); declare ED varchar(4); declare SY varchar(5); declare EY varchar(5); declare Ongo varchar(5); declare Resp Text; declare EntGUID INT; declare venddate varchar(4); declare vstartyear varchar(4); declare vstartdate varchar(4); declare vschool varchar(255); declare vendyear varchar(4); declare vongoing varchar(5); declare vdegree varchar(255); declare vfield varchar(255); declare vEntGuid INT; SET total = 0; SET BasicProfTotal = 0; SET SkillsPerc = 0; SET AvatarPerc = 0; SET AboutPerc = 0; SET AvatarTotal = 0; SET WorkTotal = 0; SET WorkPerc = 0; SET EduTotal = 0; SET EduPerc = 0; SET BasicProfPerc = 2; SELECT count(A.entity_guid) INTO vAvatar FROM prefix_metadata as A INNER JOIN prefix_metastrings as B ON A.name_id = B.id INNER JOIN prefix_entities as ent ON ent.guid=A.entity_guid WHERE ent.subtype='user' AND B.string = 'icontime' AND A.value_id NOT IN( SELECT id FROM prefix_metastrings WHERE string ='') AND A.owner_guid = UserGUID and A.entity_guid=UserGUID; IF vAvatar <> 0 THEN SET total:=total+1; SET AvatarTotal = AvatarTotal + 1; END IF; IF AvatarTotal > 0 THEN SET AvatarPerc=((AvatarTotal/1)*100); ELSE SET AvatarPerc = 0; END IF; SELECT count(A.entity_guid) INTO SkillsTotalMin FROM prefix_metadata as A INNER JOIN prefix_metastrings as B ON A.name_id = B.id WHERE B.string='gc_skills' AND A.owner_guid=UserGUID; IF SkillsTotalMin>3 THEN SET SkillsTotalMin=3; SET total:=total+3; ELSE SET total:=total+SkillsTotalMin; END IF; IF SkillsTotalMin > 0 THEN SET SkillsPerc=((SkillsTotalMin/3)*100); ELSE SET SkillsPerc = 0; END IF; SELECT count(A.entity_guid) INTO vDeptarment FROM prefix_metadata as A INNER JOIN prefix_metastrings as B ON A.name_id = B.id WHERE B.string='department' AND A.value_id NOT IN( SELECT id FROM prefix_metastrings WHERE string ='') AND A.owner_guid=UserGUID and A.entity_guid=UserGUID; IF vDeptarment <> 0 THEN SET total:=total+1; END IF; SET BasicProfTotal:=BasicProfTotal+vDeptarment; SELECT count(A.entity_guid) INTO vTitle FROM prefix_metadata as A INNER JOIN prefix_metastrings as B ON A.name_id = B.id WHERE B.string='job' AND A.value_id NOT IN( SELECT id FROM prefix_metastrings WHERE string ='') AND A.owner_guid=UserGUID and A.entity_guid=UserGUID; IF vTitle <> 0 THEN SET total:=total+1; END IF; SET BasicProfTotal:=BasicProfTotal+vTitle; SELECT count(A.entity_guid) INTO vLocation FROM prefix_metadata as A INNER JOIN prefix_metastrings as B ON A.name_id = B.id WHERE B.string='location' AND A.value_id NOT IN( SELECT id FROM prefix_metastrings WHERE string ='') AND A.owner_guid=UserGUID and A.entity_guid=UserGUID; IF vLocation <> 0 THEN SET total:=total+1; END IF; SET BasicProfTotal:=BasicProfTotal+vLocation; SELECT count(A.entity_guid) INTO vPhone FROM prefix_metadata as A INNER JOIN prefix_metastrings as B ON A.name_id = B.id WHERE B.string='phone' AND A.value_id NOT IN ( SELECT id FROM prefix_metastrings WHERE string ='' ) AND A.owner_guid=UserGUID and A.entity_guid=UserGUID; IF vPhone <> 0 THEN SET total:=total+1; END IF; SET BasicProfTotal:=BasicProfTotal+vPhone; IF vPhone=0 THEN SELECT count(A.entity_guid) INTO vMobile FROM prefix_metadata as A INNER JOIN prefix_metastrings as B ON A.name_id = B.id WHERE B.string='mobile' AND A.value_id NOT IN ( SELECT id FROM prefix_metastrings WHERE string ='' ) AND A.owner_guid=UserGUID and A.entity_guid=UserGUID; IF vMobile <> 0 THEN SET total:=total+1; END IF; SET BasicProfTotal:=BasicProfTotal+vMobile; END IF; SELECT count(A.entity_guid) INTO vWeb FROM prefix_metadata as A INNER JOIN prefix_metastrings as B ON A.name_id = B.id WHERE B.string='website' AND A.value_id NOT IN ( SELECT id FROM prefix_metastrings WHERE string ='' ) AND A.owner_guid=UserGUID and A.entity_guid=UserGUID; IF vWeb <> 0 THEN SET total:=total+1; END IF; SET BasicProfTotal:=BasicProfTotal+vWeb; IF BasicProfTotal > 0 THEN SET BasicProfPerc=((BasicProfTotal/5)*100); ELSE SET BasicProfPerc = 0; END IF; SELECT count(owner_guid) INTO vWork FROM vexperience_pivot WHERE ( organization<>'' AND startdate<>'' AND startyear<>'' AND enddate<>'' AND ( endyear<>'' OR ( ongoing='true' ) ) AND responsibilities<>'' ) AND owner_guid=UserGUID; IF vWork <> 0 THEN SET total := total + 7; SET WorkPerc := 100; ELSE IF EXISTS ( SELECT E.organization FROM vexperience_pivot as E WHERE E.owner_guid = UserGUID AND E.entity_guid IN (SELECT entity_guid FROM vexperience_pivot as E WHERE owner_guid = UserGUID) AND E.organization <> '' ) THEN SET WorkTotal := WorkTotal+1; SET total := total+1; END IF; IF EXISTS ( SELECT E.startdate FROM vexperience_pivot as E WHERE owner_guid = UserGUID AND entity_guid IN (SELECT entity_guid FROM vexperience_pivot as E WHERE owner_guid = UserGUID) AND E.startdate <> '' ) THEN SET WorkTotal:=WorkTotal+1; SET total:=total+1; END IF; IF EXISTS ( SELECT E.enddate FROM vexperience_pivot as E WHERE owner_guid = UserGUID AND entity_guid IN (SELECT entity_guid FROM vexperience_pivot as E WHERE owner_guid = UserGUID) AND E.enddate <> '' ) THEN SET WorkTotal:=WorkTotal+1; SET total:=total+1; END IF; IF EXISTS ( SELECT E.startyear FROM vexperience_pivot as E WHERE owner_guid = UserGUID AND entity_guid IN (SELECT entity_guid FROM vexperience_pivot as E WHERE owner_guid = UserGUID) AND E.startyear <> '' ) THEN SET WorkTotal:=WorkTotal+1; SET total:=total+1; END IF; IF EXISTS ( SELECT E.endyear FROM vexperience_pivot as E WHERE owner_guid = UserGUID AND entity_guid IN (SELECT entity_guid FROM vexperience_pivot as E WHERE owner_guid = UserGUID) AND E.endyear <> '' AND ongoing='false' ) THEN SET WorkTotal:=WorkTotal+1; SET total:=total+1; END IF; IF EXISTS ( SELECT E.endyear FROM vexperience_pivot as E WHERE owner_guid = UserGUID AND entity_guid IN (SELECT entity_guid FROM vexperience_pivot as E WHERE owner_guid = UserGUID) AND E.endyear = '' AND ongoing='true' ) THEN SET WorkTotal:=WorkTotal+1; SET total:=total+1; END IF; IF EXISTS ( SELECT E.responsibilities FROM vexperience_pivot as E WHERE owner_guid = UserGUID AND entity_guid IN (SELECT entity_guid FROM vexperience_pivot as E WHERE owner_guid = UserGUID) AND E.responsibilities <> '' ) THEN SET WorkTotal:=WorkTotal+1; SET total:=total+1; END IF; IF WorkTotal > 0 THEN SET WorkPerc:=((WorkTotal/7)*100); ELSE SET WorkPerc:= 0; END IF ; END IF; SELECT count(owner_guid) INTO vEductation FROM veducation_pivot WHERE ( school <> '' AND startdate <> '' AND startyear <> '' AND enddate <> '' AND ( endyear<>'' OR ( ongoing='true' ) ) AND field <> '' AND degree<>'' ) AND owner_guid = UserGUID; IF vEductation > 0 THEN SET EduPerc:=100; SET total:=total+7; ELSE IF EXISTS ( SELECT E.startyear FROM veducation_pivot as E WHERE owner_guid = UserGUID AND entity_guid IN ( SELECT entity_guid FROM veducation_pivot as E WHERE owner_guid = UserGUID ) AND E.startyear <> '' ) THEN SET EduTotal:=EduTotal+1; SET total:=total+1; END IF; IF EXISTS ( SELECT E.startdate FROM veducation_pivot as E WHERE owner_guid = UserGUID AND entity_guid IN ( SELECT entity_guid FROM veducation_pivot as E WHERE owner_guid = UserGUID ) AND E.startdate <> '' ) THEN SET EduTotal:=EduTotal+1; SET total:=total+1; END IF; IF EXISTS ( SELECT E.endyear FROM veducation_pivot as E WHERE owner_guid = UserGUID AND entity_guid IN ( SELECT entity_guid FROM veducation_pivot as E WHERE owner_guid = UserGUID ) AND E.endyear <> '' ) THEN SET EduTotal:=EduTotal+1; SET total:=total+1; END IF; IF EXISTS ( SELECT E.school FROM veducation_pivot as E WHERE owner_guid = UserGUID AND entity_guid IN ( SELECT entity_guid FROM veducation_pivot as E WHERE owner_guid = UserGUID ) AND E.school <> '' ) THEN SET EduTotal:=EduTotal+1; SET total:=total+1; END IF; IF EXISTS ( SELECT E.ongoing FROM vexperience_pivot as E WHERE owner_guid=UserGUID AND entity_guid IN ( SELECT entity_guid FROM veducation_pivot as E WHERE owner_guid = UserGUID ) AND vongoing = 'false' AND vendyear <> '' ) OR EXISTS ( SELECT E.ongoing FROM vexperience_pivot as E WHERE owner_guid=UserGUID AND entity_guid IN ( SELECT entity_guid FROM veducation_pivot as E WHERE owner_guid = UserGUID ) AND vongoing='true' AND vendyear = '' ) THEN SET EduTotal:=EduTotal+1; SET total:=total+1; END IF; IF EXISTS ( SELECT E.degree FROM veducation_pivot as E WHERE owner_guid=UserGUID AND entity_guid IN ( SELECT entity_guid FROM veducation_pivot as E WHERE owner_guid = UserGUID ) AND E.degree <> '' ) THEN SET EduTotal:=EduTotal+1; SET total:=total+1; END IF; IF EXISTS ( SELECT E.field FROM veducation_pivot as E WHERE owner_guid=UserGUID AND entity_guid IN ( SELECT entity_guid FROM veducation_pivot as E WHERE owner_guid = UserGUID ) AND E.field <> '' ) THEN SET EduTotal:=EduTotal+1; SET total:=total+1; END IF; IF EduTotal > 0 THEN SET EduPerc:=((EduTotal/7)*100); ELSE SET EduPerc:= 0; END IF ; END IF; SELECT count(A.entity_guid) INTO vAboutMe FROM prefix_metadata as A INNER JOIN prefix_metastrings as B ON A.name_id = B.id WHERE B.string='description' AND A.value_id NOT IN ( SELECT id FROM prefix_metastrings WHERE string ='' ) and A.owner_guid=UserGUID; IF vAboutMe=0 THEN SET total:=total+0; SET AboutPerc=0; ELSE SET total:=total+1; SET AboutPerc=100; END IF; SET total:=((total/24)*100); if total=0 then SET total=2; END IF; END;