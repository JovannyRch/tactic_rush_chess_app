create temp table mapingo_state_seed (
  region_name text not null,
  name text not null,
  capital text not null,
  abbreviation text not null,
  description text not null,
  fun_fact text not null,
  map_key text not null,
  color_hex text not null,
  order_index integer not null
) on commit drop;

insert into mapingo_state_seed (region_name, name, capital, abbreviation, description, fun_fact, map_key, color_hex, order_index) values
('Northern Mexico', 'Baja California', 'Mexicali', 'BCN', 'Baja California is a border state on the Baja California peninsula, known for the Pacific coast, the Gulf of California, and the Guadalupe Valley wine region.', 'Mexicali is one of Mexico''s warmest state capitals and sits next to the United States border.', 'baja_california', '#1CB0F6', 1),
('Northern Mexico', 'Baja California Sur', 'La Paz', 'BCS', 'Baja California Sur occupies the southern half of the peninsula and is known for deserts, beaches, islands, and marine life.', 'The gray whale migration can be observed in lagoons along Baja California Sur.', 'baja_california_sur', '#58CC02', 2),
('Northern Mexico', 'Sonora', 'Hermosillo', 'SON', 'Sonora is a large northwestern state with desert landscapes, cattle ranching, beaches on the Gulf of California, and a long border with the United States.', 'The Sonoran Desert is one of the most biodiverse deserts in North America.', 'sonora', '#FFC800', 3),
('Northern Mexico', 'Chihuahua', 'Chihuahua', 'CHH', 'Chihuahua is Mexico''s largest state by area, with deserts, mountains, border cities, and the Copper Canyon region.', 'Copper Canyon is a network of canyons larger and deeper in parts than the Grand Canyon.', 'chihuahua', '#FF9600', 4),
('Northern Mexico', 'Coahuila', 'Saltillo', 'COA', 'Coahuila is a northern state known for desert ecosystems, fossils, industry, and the historic wine area of Parras.', 'Parras de la Fuente is one of the oldest wine-producing areas in the Americas.', 'coahuila', '#7AC943', 5),
('Northern Mexico', 'Nuevo León', 'Monterrey', 'NLE', 'Nuevo León is a northeastern state centered on Monterrey, an important industrial and business city framed by mountains.', 'The Cerro de la Silla is one of Monterrey''s most recognizable natural landmarks.', 'nuevo_leon', '#00A6D6', 6),
('Northern Mexico', 'Tamaulipas', 'Ciudad Victoria', 'TAM', 'Tamaulipas lies on the Gulf of Mexico and the United States border, with coastal wetlands, ports, ranching areas, and border cities.', 'Tamaulipas includes Laguna Madre, one of Mexico''s important coastal lagoon systems.', 'tamaulipas', '#F15A24', 7),
('Northern Mexico', 'Durango', 'Durango', 'DUR', 'Durango is a northwestern state with Sierra Madre mountains, colonial architecture, forests, and desert zones.', 'Many western films were shot in Durango because of its open desert landscapes.', 'durango', '#9B5DE5', 8),
('Northern Mexico', 'Sinaloa', 'Culiacán Rosales', 'SIN', 'Sinaloa is a Pacific coastal state known for agriculture, fishing, Mazatlán, and fertile valleys.', 'Sinaloa is one of Mexico''s most important agricultural producers.', 'sinaloa', '#00BBF9', 9),
('Northern Mexico', 'Zacatecas', 'Zacatecas', 'ZAC', 'Zacatecas is a north-central state with a historic silver-mining city, highland landscapes, and colonial architecture.', 'The historic center of Zacatecas is a UNESCO World Heritage Site.', 'zacatecas', '#FEE440', 10),
('Western Mexico', 'Nayarit', 'Tepic', 'NAY', 'Nayarit is a Pacific state with beaches, islands, mountains, and cultural traditions from Indigenous communities such as the Wixárika.', 'The Marietas Islands are one of Nayarit''s best-known natural attractions.', 'nayarit', '#43AA8B', 11),
('Western Mexico', 'Jalisco', 'Guadalajara', 'JAL', 'Jalisco is a western state known for Guadalajara, mariachi, tequila, Lake Chapala, and strong cultural traditions.', 'Jalisco is widely known as a birthplace of mariachi music and tequila production.', 'jalisco', '#90BE6D', 12),
('Western Mexico', 'Colima', 'Colima', 'COL', 'Colima is a small Pacific state with volcano views, coastal areas, agriculture, and a compact capital city.', 'Colima is one of Mexico''s smallest states by area.', 'colima', '#F94144', 13),
('Western Mexico', 'Michoacán', 'Morelia', 'MIC', 'Michoacán is a western state known for Morelia, Lake Pátzcuaro, Purépecha culture, forests, and monarch butterfly reserves.', 'Millions of monarch butterflies spend the winter in mountain forests of Michoacán and Estado de México.', 'michoacan', '#F3722C', 14),
('Western Mexico', 'Aguascalientes', 'Aguascalientes', 'AGU', 'Aguascalientes is a small central-western state known for industry, rail history, vineyards, and the city of Aguascalientes.', 'The Feria Nacional de San Marcos in Aguascalientes is one of Mexico''s largest fairs.', 'aguascalientes', '#577590', 15),
('Western Mexico', 'Guanajuato', 'Guanajuato', 'GUA', 'Guanajuato is a Bajío state known for colonial cities, mining history, independence-era sites, and cultural festivals.', 'The city of Guanajuato grew around rich silver mines during the colonial period.', 'guanajuato', '#277DA1', 16),
('Central Mexico', 'Querétaro', 'Santiago de Querétaro', 'QUE', 'Querétaro is a central state with colonial architecture, aqueducts, vineyards, mountains, and important independence history.', 'The aqueduct of Querétaro is one of the city''s most famous landmarks.', 'queretaro', '#4D908E', 17),
('Central Mexico', 'Hidalgo', 'Pachuca de Soto', 'HID', 'Hidalgo is a central state known for mining heritage, mountain towns, basaltic prisms, and the ancient Toltec site of Tula.', 'The Atlantes of Tula are large stone warrior figures from the Toltec culture.', 'hidalgo', '#F8961E', 18),
('Central Mexico', 'Estado de México', 'Toluca de Lerdo', 'MEX', 'Estado de México surrounds much of Mexico City and includes Toluca, volcanoes, archaeological sites, forests, and dense urban areas.', 'Nevado de Toluca is a volcano with crater lakes near the state capital.', 'estado_de_mexico', '#F9844A', 19),
('Central Mexico', 'Ciudad de México', 'Ciudad de México', 'CMX', 'Ciudad de México is Mexico''s capital and a federal entity, home to national government, major museums, historic neighborhoods, and ancient Mexica heritage.', 'The historic center of Ciudad de México and Xochimilco are recognized by UNESCO.', 'ciudad_de_mexico', '#7209B7', 20),
('Central Mexico', 'Morelos', 'Cuernavaca', 'MOR', 'Morelos is a small central state known for warm weather, gardens, history, and the city of Cuernavaca.', 'Cuernavaca is often called the City of Eternal Spring because of its pleasant climate.', 'morelos', '#B5179E', 21),
('Central Mexico', 'Tlaxcala', 'Tlaxcala de Xicohténcatl', 'TLA', 'Tlaxcala is Mexico''s smallest state by area and is known for colonial towns, archaeology, forests, and traditions.', 'Tlaxcala is the smallest state in Mexico.', 'tlaxcala', '#4895EF', 22),
('Central Mexico', 'Puebla', 'Puebla de Zaragoza', 'PUE', 'Puebla is a central state known for volcano views, Talavera pottery, colonial architecture, industry, and important cuisine.', 'Puebla is strongly associated with mole poblano and Talavera pottery.', 'puebla', '#4361EE', 23),
('Central Mexico', 'San Luis Potosí', 'San Luis Potosí', 'SLP', 'San Luis Potosí links northern and central Mexico, with deserts, colonial cities, mining history, and the waterfalls of the Huasteca region.', 'The Huasteca Potosina is famous for turquoise rivers and waterfalls.', 'san_luis_potosi', '#3A0CA3', 24),
('Southern Mexico', 'Guerrero', 'Chilpancingo de los Bravo', 'GRO', 'Guerrero is a southern Pacific state known for beaches, mountains, silverwork in Taxco, and the port city of Acapulco.', 'Taxco is famous for silver craftsmanship and steep colonial streets.', 'guerrero', '#FF006E', 25),
('Southern Mexico', 'Oaxaca', 'Oaxaca de Juárez', 'OAX', 'Oaxaca is a southern state known for Indigenous cultures, languages, cuisine, mountains, beaches, and archaeological sites.', 'Monte Albán near Oaxaca de Juárez was an important Zapotec city.', 'oaxaca', '#FB5607', 26),
('Southern Mexico', 'Chiapas', 'Tuxtla Gutiérrez', 'CHP', 'Chiapas is a southern state with rainforests, highlands, Maya archaeological sites, rivers, and strong Indigenous cultural diversity.', 'The Sumidero Canyon rises dramatically above the Grijalva River near Tuxtla Gutiérrez.', 'chiapas', '#FFBE0B', 27),
('Southern Mexico', 'Veracruz', 'Xalapa-Enríquez', 'VER', 'Veracruz stretches along the Gulf of Mexico and is known for ports, mountains, coffee regions, music, and coastal plains.', 'The port of Veracruz has been one of Mexico''s most important Gulf ports for centuries.', 'veracruz', '#06D6A0', 28),
('Southern Mexico', 'Tabasco', 'Villahermosa', 'TAB', 'Tabasco is a Gulf lowland state known for rivers, wetlands, cacao, tropical vegetation, and Olmec heritage.', 'The Olmec colossal heads at La Venta are among Mexico''s famous ancient monuments.', 'tabasco', '#118AB2', 29),
('Southeast Mexico', 'Campeche', 'San Francisco de Campeche', 'CAM', 'Campeche is a southeastern Gulf state known for its walled capital city, Maya sites, wetlands, and coastal history.', 'The historic fortified city of Campeche is a UNESCO World Heritage Site.', 'campeche', '#EF476F', 30),
('Southeast Mexico', 'Yucatán', 'Mérida', 'YUC', 'Yucatán is a peninsula state known for Mérida, Maya heritage, cenotes, haciendas, and archaeological sites such as Chichén Itzá.', 'Chichén Itzá is one of Mexico''s most visited archaeological sites.', 'yucatan', '#FFD166', 31),
('Southeast Mexico', 'Quintana Roo', 'Chetumal', 'ROO', 'Quintana Roo is a Caribbean state known for Chetumal, Cancún, the Riviera Maya, coral reefs, and Maya archaeological sites.', 'The Sian Ka''an Biosphere Reserve in Quintana Roo is a UNESCO World Heritage Site.', 'quintana_roo', '#073B4C', 32);

insert into public.regions (name, description, order_index)
values
('Northern Mexico', 'Northern states with borderlands, deserts, mountains, Pacific and Gulf coasts, and major industrial cities.', 1),
('Western Mexico', 'Western and Bajío states known for Pacific coastlines, colonial cities, mariachi, tequila, agriculture, and mining history.', 2),
('Central Mexico', 'Central highland states around the national capital, with dense cities, volcanoes, colonial heritage, and major historic sites.', 3),
('Southern Mexico', 'Southern states with Pacific and Gulf coasts, mountains, Indigenous cultures, rainforests, and major archaeological heritage.', 4),
('Southeast Mexico', 'Peninsula and Caribbean states known for Maya heritage, cenotes, beaches, wetlands, and tropical ecosystems.', 5),
('Full Mexico Review', 'A final review region that mixes all 32 states, capitals, map keys, and regional facts.', 6)
on conflict (name) do update set
  description = excluded.description,
  order_index = excluded.order_index;

insert into public.states (region_id, name, capital, abbreviation, description, fun_fact, map_key, color_hex, order_index)
select r.id, s.name, s.capital, s.abbreviation, s.description, s.fun_fact, s.map_key, s.color_hex, s.order_index
from mapingo_state_seed s
join public.regions r on r.name = s.region_name
on conflict (name) do update set
  region_id = excluded.region_id,
  capital = excluded.capital,
  abbreviation = excluded.abbreviation,
  description = excluded.description,
  fun_fact = excluded.fun_fact,
  map_key = excluded.map_key,
  color_hex = excluded.color_hex,
  order_index = excluded.order_index;

insert into public.units (region_id, title, description, order_index, is_active)
select r.id, u.title, u.description, u.order_index, true
from (values
  ('Northern Mexico', 'Unit 1: Northern Mexico', 'Learn the northern states, capitals, borders, deserts, mountains, and map locations.', 1),
  ('Western Mexico', 'Unit 2: Western Mexico', 'Practice the western and Bajío states, their capitals, cultural facts, and map positions.', 2),
  ('Central Mexico', 'Unit 3: Central Mexico', 'Explore the central highland states, the national capital area, and nearby capitals.', 3),
  ('Southern Mexico', 'Unit 4: Southern Mexico', 'Study southern states with Pacific and Gulf coasts, mountains, rivers, and cultural regions.', 4),
  ('Southeast Mexico', 'Unit 5: Southeast Mexico', 'Practice the peninsula and Caribbean states, capitals, and Maya-region geography.', 5),
  ('Full Mexico Review', 'Unit 6: Full Mexico Review', 'Review all 32 states, capitals, map keys, and regional facts together.', 6)
) as u(region_name, title, description, order_index)
join public.regions r on r.name = u.region_name
where not exists (select 1 from public.units existing where existing.title = u.title);

insert into public.lessons (unit_id, title, description, lesson_type, order_index, xp_reward, is_active)
select u.id, l.title, l.description, l.lesson_type, l.order_index, l.xp_reward, true
from public.units u
join (values
  ('1. Region Intro', 'Meet the states in this unit with names, regions, map keys, and short facts.', 'standard', 1, 10),
  ('2. Capitals', 'Practice matching each state in this unit with its capital city.', 'capital_practice', 2, 12),
  ('3. Map Practice', 'Tap and identify state locations using the map_key for each state.', 'map_practice', 3, 12),
  ('4. Review', 'Review state names, capitals, map locations, pairs, and true-or-false facts.', 'review', 4, 15)
) as l(title, description, lesson_type, order_index, xp_reward) on true
where u.title in ('Unit 1: Northern Mexico', 'Unit 2: Western Mexico', 'Unit 3: Central Mexico', 'Unit 4: Southern Mexico', 'Unit 5: Southeast Mexico', 'Unit 6: Full Mexico Review')
  and not exists (select 1 from public.lessons existing where existing.unit_id = u.id and existing.title = l.title);

update public.lessons l
set required_lesson_id = previous.id
from public.lessons previous
where previous.unit_id = l.unit_id
  and previous.order_index = l.order_index - 1
  and l.order_index > 1
  and l.required_lesson_id is null;

insert into public.achievements (code, title, description, icon, xp_reward, condition_type, condition_value, is_active)
values
('first_lesson', 'First Lesson', 'Complete your first Mapingo lesson.', 'flag', 25, 'lessons_completed', 1, true),
('capital_starter', 'Capital Starter', 'Answer 10 capital questions correctly.', 'school', 25, 'capital_questions_correct', 10, true),
('map_tapper', 'Map Tapper', 'Answer 10 map tap exercises correctly.', 'map-pin', 25, 'map_tap_correct', 10, true),
('north_explorer', 'North Explorer', 'Complete the Northern Mexico unit.', 'compass', 50, 'units_completed', 1, true),
('west_explorer', 'West Explorer', 'Complete the Western Mexico unit.', 'music', 50, 'units_completed', 2, true),
('center_explorer', 'Center Explorer', 'Complete the Central Mexico unit.', 'landmark', 50, 'units_completed', 3, true),
('south_explorer', 'South Explorer', 'Complete the Southern Mexico unit.', 'mountain', 50, 'units_completed', 4, true),
('southeast_explorer', 'Southeast Explorer', 'Complete the Southeast Mexico unit.', 'waves', 50, 'units_completed', 5, true),
('perfect_lesson', 'Perfect Lesson', 'Finish any lesson with 100 percent accuracy.', 'star', 75, 'perfect_lessons', 1, true),
('mexico_master', 'Mexico Master', 'Complete the full Mexico review unit.', 'trophy', 100, 'units_completed', 6, true)
on conflict (code) do update set
  title = excluded.title,
  description = excluded.description,
  icon = excluded.icon,
  xp_reward = excluded.xp_reward,
  condition_type = excluded.condition_type,
  condition_value = excluded.condition_value,
  is_active = excluded.is_active;

with lesson_scope as (
  select l.id as lesson_id, l.order_index as lesson_order, l.title as lesson_title, u.region_id, r.name as region_name
  from public.lessons l
  join public.units u on u.id = l.unit_id
  join public.regions r on r.id = u.region_id
  where u.title in ('Unit 1: Northern Mexico', 'Unit 2: Western Mexico', 'Unit 3: Central Mexico', 'Unit 4: Southern Mexico', 'Unit 5: Southeast Mexico', 'Unit 6: Full Mexico Review')
), state_pool as (
  select ls.lesson_id, st.id as state_id, st.name, st.capital, st.map_key, st.description, st.fun_fact, st.order_index,
    row_number() over (partition by ls.lesson_id order by st.order_index) as rn,
    count(*) over (partition by ls.lesson_id) as cnt
  from lesson_scope ls
  join public.states st on ls.region_name = 'Full Mexico Review' or st.region_id = ls.region_id
), generated_exercises as (
  select ls.lesson_id, gs.order_index,
    case
      when ls.lesson_order = 1 then case ((gs.order_index - 1) % 5)
        when 0 then 'multiple_choice_state'
        when 1 then 'multiple_choice_capital'
        when 2 then 'map_tap'
        when 3 then 'true_false'
        else 'match_pairs'
      end
      when ls.lesson_order = 2 then case
        when gs.order_index in (1,2,3,4) then 'multiple_choice_capital'
        when gs.order_index in (5,6) then 'multiple_choice_state'
        when gs.order_index in (7,8) then 'match_pairs'
        else 'true_false'
      end
      when ls.lesson_order = 3 then case
        when gs.order_index <= 7 then 'map_tap'
        when gs.order_index = 8 then 'multiple_choice_state'
        when gs.order_index = 9 then 'match_pairs'
        else 'true_false'
      end
      else case ((gs.order_index - 1) % 5)
        when 0 then 'multiple_choice_state'
        when 1 then 'multiple_choice_capital'
        when 2 then 'map_tap'
        when 3 then 'match_pairs'
        else 'true_false'
      end
    end as exercise_type,
    target.name as state_name,
    target.capital,
    target.map_key,
    target.fun_fact,
    target.description,
    false_capital.capital as distractor_capital,
    state_options.options as state_options,
    capital_options.options as capital_options,
    match_data.pairs as match_pairs
  from lesson_scope ls
  cross join generate_series(1, 10) as gs(order_index)
  join state_pool target on target.lesson_id = ls.lesson_id and target.rn = ((gs.order_index - 1) % target.cnt) + 1
  cross join lateral (
    select other.capital
    from public.states other
    where other.name <> target.name
    order by md5(other.name || target.name || gs.order_index::text)
    limit 1
  ) false_capital
  cross join lateral (
    select jsonb_agg(option_name order by option_order) as options
    from (
      select target.name as option_name, 0 as option_order
      union all
      select d.name, row_number() over (order by md5(d.name || target.name || gs.order_index::text)) as option_order
      from public.states d
      where d.name <> target.name
      order by option_order
      limit 3
    ) options_src
  ) state_options
  cross join lateral (
    select jsonb_agg(option_capital order by option_order) as options
    from (
      select target.capital as option_capital, 0 as option_order
      union all
      select d.capital, row_number() over (order by md5(d.capital || target.capital || gs.order_index::text)) as option_order
      from public.states d
      where d.name <> target.name
      order by option_order
      limit 3
    ) options_src
  ) capital_options
  cross join lateral (
    select jsonb_agg(jsonb_build_object('left', p.name, 'right', p.capital) order by p.sort_order) as pairs
    from (
      select sp.name, sp.capital, ((sp.rn - gs.order_index + sp.cnt) % sp.cnt) as sort_order
      from state_pool sp
      where sp.lesson_id = ls.lesson_id
      order by sort_order, sp.rn
      limit 4
    ) p
  ) match_data
)
insert into public.exercises (lesson_id, exercise_type, question, correct_answer, options, metadata, explanation, difficulty, order_index, is_active)
select ge.lesson_id,
  ge.exercise_type,
  case ge.exercise_type
    when 'multiple_choice_state' then 'Which state has the capital ' || ge.capital || '?'
    when 'multiple_choice_capital' then 'What is the capital of ' || ge.state_name || '?'
    when 'map_tap' then 'Tap ' || ge.state_name || ' on the map.'
    when 'match_pairs' then 'Match each state with its capital.'
    when 'true_false' then case when ge.order_index % 2 = 0
      then 'True or false: The capital of ' || ge.state_name || ' is ' || ge.capital || '.'
      else 'True or false: The capital of ' || ge.state_name || ' is ' || ge.distractor_capital || '.'
    end
  end as question,
  case ge.exercise_type
    when 'multiple_choice_state' then ge.state_name
    when 'multiple_choice_capital' then ge.capital
    when 'map_tap' then ge.map_key
    when 'match_pairs' then 'pairs'
    when 'true_false' then case when ge.order_index % 2 = 0 then 'true' else 'false' end
  end as correct_answer,
  case ge.exercise_type
    when 'multiple_choice_state' then ge.state_options
    when 'multiple_choice_capital' then ge.capital_options
    when 'true_false' then '["true", "false"]'::jsonb
    else null::jsonb
  end as options,
  case ge.exercise_type
    when 'map_tap' then jsonb_build_object('targetStateKey', ge.map_key, 'state', ge.state_name)
    when 'match_pairs' then jsonb_build_object('pairs', ge.match_pairs)
    when 'multiple_choice_state' then jsonb_build_object('capital', ge.capital, 'state', ge.state_name, 'mapKey', ge.map_key)
    when 'multiple_choice_capital' then jsonb_build_object('state', ge.state_name, 'capital', ge.capital, 'mapKey', ge.map_key)
    when 'true_false' then jsonb_build_object('state', ge.state_name, 'capital', ge.capital, 'mapKey', ge.map_key)
  end as metadata,
  case ge.exercise_type
    when 'multiple_choice_state' then ge.capital || ' is the capital of ' || ge.state_name || '.'
    when 'multiple_choice_capital' then 'The capital of ' || ge.state_name || ' is ' || ge.capital || '.'
    when 'map_tap' then ge.state_name || ' uses the map key ' || ge.map_key || '.'
    when 'match_pairs' then 'Each pair connects a Mexican state with its official capital.'
    when 'true_false' then case when ge.order_index % 2 = 0
      then 'Correct: ' || ge.capital || ' is the capital of ' || ge.state_name || '.'
      else 'False: the capital of ' || ge.state_name || ' is ' || ge.capital || '.'
    end
  end as explanation,
  case when ge.exercise_type in ('match_pairs', 'map_tap') then 2 else 1 end as difficulty,
  ge.order_index,
  true
from generated_exercises ge
where not exists (
  select 1
  from public.exercises existing
  where existing.lesson_id = ge.lesson_id
    and existing.order_index = ge.order_index
);;
