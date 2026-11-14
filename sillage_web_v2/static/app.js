'use strict';
(() => {
  const $ = (s, root = document) => root.querySelector(s);
  const $$ = (s, root = document) => [...root.querySelectorAll(s)];
  const esc = v => String(v ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  const money = v => new Intl.NumberFormat('en-US', {style:'currency', currency:'USD', maximumFractionDigits:2}).format(Number(v || 0));
  const pad = n => String(n).padStart(2,'0');
  const reduced = matchMedia('(prefers-reduced-motion: reduce)');
  const tints = ['#9aaa8c','#a9a483','#7f9a72','#5e6f55','#c9cfbc','#8c9a6e','#b3ae98','#8e968a','#a4b48a'];
  const bottle = p => `<span class="bottle-cap"></span><span class="bottle-body" style="--tint:${tints[p.id % tints.length]}"></span>`;
  const sniffIcon = '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 3c-1.2 1.4 1.2 2.6 0 4M12 2c-1.2 1.4 1.2 2.6 0 4M16 3c-1.2 1.4 1.2 2.6 0 4M5 13h14M6 13l1.4 7.2a1 1 0 0 0 1 .8h7.2a1 1 0 0 0 1-.8L18 13M9.5 16.5l1.5 1.5 3.5-3.5"/></svg>';
  const state = {products:[],brands:[],countries:[],stores:[],mode:'note',group:'Vetiver',slides:[],pos:4,target:null,velocity:0,speed:0,active:-1,hover:false,drag:null,paused:reduced.matches,filter:null,limit:24,bag:[],csrf:'',preview:false,staff:false,staff_enabled:false};
  try { const saved = JSON.parse(sessionStorage.getItem('sillage-bag') || '[]'); state.bag = Array.isArray(saved) ? saved.filter(Number.isInteger) : []; } catch (_) {}
  const modal = $('#modal'), carousel = $('#carousel');
  let toastTimer, lastFrame = performance.now(), swallow = false;

  async function api(path, data) {
    if (window.SILLAGE_PREVIEW) {
      if (path === '/api/catalog') return window.SILLAGE_PREVIEW;
      if (path === '/api/status') return {preview:true,staff:false,staff_enabled:false,csrf:''};
      throw new Error('This is the catalogue preview. Run the Python app with MySQL to use this feature.');
    }
    const res = await fetch(path, {method:data ? 'POST':'GET', credentials:'same-origin', headers:data ? {'Content-Type':'application/json','X-CSRF-Token':state.csrf} : {}, ...(data ? {body:JSON.stringify(data)} : {})});
    const payload = await res.json();
    if (!res.ok) throw new Error(payload.error || payload.message || 'The request could not be completed.');
    return payload;
  }
  function toast(message) { $('#toast').textContent = message; $('#toast').hidden = false; clearTimeout(toastTimer); toastTimer = setTimeout(() => $('#toast').hidden = true, 4200); }
  function openModal(view, html, wide=false) {
    modal.dataset.view = view; modal.classList.toggle('wide', wide); $('#modal-content').innerHTML = html;
    if (!modal.open) modal.showModal();
    modal.scrollTop = 0;
    const first = $('input:not([type=hidden]),select', modal); if (first) first.focus();
  }
  function result(message, error=false, target='#form-result') {
    const node = $(target, modal); if (!node) return;
    node.hidden = false; node.className = 'result' + (error ? ' error' : ''); node.textContent = message;
  }
  const resultBox = '<div class="result" id="form-result" role="status" hidden></div>';
  function groups(mode=state.mode) {
    return [...new Set(state.products.flatMap(p => mode === 'house' ? [p.house] : p[mode === 'note' ? 'notes':'ingredients']))].sort((a,b)=>a.localeCompare(b));
  }
  function inGroup(p, mode=state.mode, group=state.group) { return mode === 'house' ? p.house === group : p[mode === 'note' ? 'notes':'ingredients'].includes(group); }
  function setMode(mode, group) {
    const values = groups(mode); state.mode = mode;
    state.group = group && values.includes(group) ? group : (mode === 'note' && values.includes('Vetiver') ? 'Vetiver' : values[0] || 'THE COLLECTION');
    $$('.mode-tabs button').forEach(b => b.setAttribute('aria-pressed', String(b.dataset.mode === mode)));
    renderCarousel();
  }
  function renderCarousel() {
    const products = state.products.filter(p => inGroup(p)), seen = new Set();
    state.slides = products.filter(p => { const key=p.house+'|'+p.name; if (seen.has(key)) return false; seen.add(key); return true; }).slice(0,9);
    state.pos = Math.min(4, Math.max(0,state.slides.length-1)); state.target=null; state.speed=0; state.velocity=0; state.active=-1;
    $('#eyebrow').textContent = `${state.mode.toUpperCase()} · ${seen.size} FRAGRANCES`;
    $('#group-title').textContent = state.group;
    $('#group-title').style.fontSize = state.group.length > 17 ? 'clamp(26px, 4.8vw, 56px)' : '';
    $('#big-word').textContent = state.group.toUpperCase();
    $('#explore').innerHTML = `EXPLORE ${esc(state.group.toUpperCase())} <span aria-hidden="true">→</span>`;
    $('#cards').innerHTML = state.slides.map((p,i) => `<div class="fragrance-card" data-index="${i}" role="group" aria-roledescription="slide" aria-label="${i+1} of ${state.slides.length}: ${esc(p.name)}"><button class="select-card" data-action="select-card" data-index="${i}" aria-label="Select ${esc(p.name)}"><span class="card-number">${pad(i+1)}</span>${bottle(p)}<span class="card-name">${esc(p.name)}<small>${esc(p.size)} ML</small></span></button><button class="sniff-button" data-action="sample" data-id="${p.id}" aria-label="Sample ${esc(p.name)}">${sniffIcon}</button></div>`).join('');
    $('#carousel-message').hidden = !!state.slides.length;
    $('#carousel-message').textContent = 'No fragrances in this group yet.';
    paintCarousel();
  }
  function relative(i,pos) { const n=state.slides.length; let d=((i-pos)%n+n)%n; if(d>n/2)d-=n; return d; }
  function paintCarousel() {
    const n=state.slides.length; if(!n) return;
    const near=((Math.round(state.pos)%n)+n)%n;
    const mobile=innerWidth<=680, radius=mobile?540:760, step=mobile?24:20;
    $$('.fragrance-card').forEach((card,i)=> {
      const d=relative(i,state.pos), a=d*step, lift=40*Math.max(0,1-Math.abs(d));
      const opacity=Math.max(0,Math.min(1,(78-Math.abs(a))/16));
      card.style.transform=`translateZ(${radius}px) rotateY(${a.toFixed(3)}deg) translateZ(${-radius}px) translateZ(${lift.toFixed(2)}px)`;
      card.style.opacity=opacity; card.style.zIndex=String(100-Math.round(Math.abs(d)*10)); card.style.pointerEvents=opacity<.2?'none':'';
      card.classList.toggle('selected',i===near);
      card.setAttribute('aria-hidden',String(opacity<.2));
      $$('button',card).forEach(b=>b.tabIndex=opacity<.2?-1:0);
    });
    if(near!==state.active){
      state.active=near; const p=state.slides[near];
      $('#active-house').textContent=p.house.toUpperCase(); $('#active-name').textContent=p.name;
      $('#active-notes').innerHTML=p.notes.slice(0,3).map(n=>`<span>${esc(n)}</span>`).join('');
      $('#counter').textContent=`${pad(near+1)} / ${pad(n)}`;
    }
  }
  function step(dir){state.velocity=0;state.speed=0;state.target=(state.target??Math.round(state.pos))+dir; if(reduced.matches){state.pos=state.target;state.target=null;paintCarousel();}}
  function frame(now){
    const dt=Math.min(.05,(now-lastFrame)/1000);lastFrame=now;
    if(!state.drag && state.slides.length>1 && !document.hidden){
      if(state.target!==null){state.pos+=(state.target-state.pos)*(1-Math.exp(-dt*7));if(Math.abs(state.target-state.pos)<.002){state.pos=state.target;state.target=null;}}
      else if(Math.abs(state.velocity)>.35){state.pos+=state.velocity*dt;state.velocity*=Math.pow(.04,dt);}
      else {if(state.velocity!==0){state.speed=state.velocity;state.velocity=0;}const want=(state.hover||state.paused||modal.open||reduced.matches||carousel.contains(document.activeElement))?0:.25;state.speed+=(want-state.speed)*(1-Math.exp(-dt*6));state.pos+=state.speed*dt;}
      paintCarousel();
    }
    requestAnimationFrame(frame);
  }
  function motion(){state.paused=!state.paused; state.velocity=0;state.speed=0;document.body.classList.toggle('motion-paused',state.paused);$('#motion-toggle').textContent=state.paused?'RESUME MOTION':'PAUSE MOTION';}
  carousel.addEventListener('pointerenter',()=>state.hover=true);
  carousel.addEventListener('pointerleave',()=>state.hover=false);
  carousel.addEventListener('pointerdown',e=>{if(e.button!==0||modal.open)return;state.drag={x:e.clientX,pos:state.pos,lastX:e.clientX,t:performance.now(),moved:false};state.target=null;state.velocity=0;state.speed=0;});
  carousel.addEventListener('pointermove',e=>{const d=state.drag;if(!d)return;const dx=e.clientX-d.x;if(!d.moved&&Math.abs(dx)>6){d.moved=true;carousel.setPointerCapture(e.pointerId);carousel.classList.add('dragging');}if(!d.moved)return;const t=performance.now();state.velocity=state.velocity*.7+((e.clientX-d.lastX)/230)/Math.max(.001,(t-d.t)/1000)*.3;d.lastX=e.clientX;d.t=t;state.pos=d.pos+dx/230;paintCarousel();});
  function endDrag(e){if(!state.drag)return;swallow=state.drag.moved;state.drag=null;state.velocity=Math.max(-8,Math.min(8,state.velocity));if(state.paused||reduced.matches)state.velocity=0;carousel.classList.remove('dragging');if(carousel.hasPointerCapture(e.pointerId))carousel.releasePointerCapture(e.pointerId);setTimeout(()=>swallow=false,0);}
  carousel.addEventListener('pointerup',endDrag);carousel.addEventListener('pointercancel',endDrag);
  carousel.addEventListener('click',e=>{if(swallow){e.preventDefault();e.stopPropagation();swallow=false;}},true);
  carousel.addEventListener('keydown',e=>{if(e.key==='ArrowLeft'||e.key==='ArrowRight'){e.preventDefault();step(e.key==='ArrowLeft'?-1:1);}});
  window.addEventListener('resize',paintCarousel);
  reduced.addEventListener('change',()=>{state.paused=reduced.matches;document.body.classList.toggle('motion-paused',state.paused);$('#motion-toggle').textContent=state.paused?'RESUME MOTION':'PAUSE MOTION';});

  function browse(mode=state.mode){
    openModal('browse',`<p class="eyebrow">FOLLOW YOUR CURIOSITY</p><h2 id="modal-title">Explore by ${esc(mode)}.</h2><label class="field">FIND A ${esc(mode.toUpperCase())}<input class="modal-search" id="group-search" type="search" placeholder="Start typing…"></label><div class="choice-list" id="group-choices"></div>`);
    const render=()=>{const q=$('#group-search').value.toLowerCase();$('#group-choices').innerHTML=groups(mode).filter(g=>g.toLowerCase().includes(q)).map(g=>`<button data-action="choose" data-mode="${mode}" data-group="${esc(g)}">${esc(g)}</button>`).join('')||'<p>No matching groups.</p>';};
    $('#group-search').addEventListener('input',render);render();
  }
  function renderCatalog(){
    const query=$('#catalog-search').value.trim().toLowerCase();
    let products=state.products.filter(p=>(!state.filter||inGroup(p,state.filter.mode,state.filter.group))&&(!query||[p.name,p.house,...p.notes].join(' ').toLowerCase().includes(query)));
    const sort=$('#catalog-sort').value; products.sort(sort==='low'?(a,b)=>Number(a.price)-Number(b.price):sort==='high'?(a,b)=>Number(b.price)-Number(a.price):(a,b)=>a.name.localeCompare(b.name)||a.size-b.size);
    $('#catalog-count').textContent=`${products.length} bottle${products.length===1?'':'s'}${state.filter?' · '+state.filter.group:''}`;
    $('#clear-filter').hidden=!state.filter;
    $('#product-grid').innerHTML=products.slice(0,state.limit).map((p,i)=>`<button class="product-tile" data-action="detail" data-id="${p.id}" aria-label="View ${esc(p.name)}, ${esc(p.size)} millilitres"><span class="tile-art"><span class="tile-index">${pad(i+1)}</span>${bottle(p)}</span><span class="tile-house">${esc(p.house)}</span><span class="tile-name">${esc(p.name)}</span><span class="tile-detail"><span>${esc(p.strength)} · ${esc(p.size)} ml</span><span>${money(p.price)}</span></span></button>`).join('')||'<p class="empty-state">No fragrances match. Try another name, house or note.</p>';
    $('#load-more').hidden=products.length<=state.limit;
  }
  function showCatalog(filter=null){setTab('collection');state.filter=filter;state.limit=24;$('#catalog-search').value='';renderCatalog();$('#catalog').scrollIntoView({behavior:reduced.matches?'instant':'smooth'});}
  $('#catalog-search').addEventListener('input',()=>{state.limit=24;renderCatalog();});$('#catalog-sort').addEventListener('change',renderCatalog);
  function details(id){
    const p=state.products.find(p=>p.id===id);if(!p)return;
    const stores=new Map(state.stores.map(s=>[s.id,s]));
    openModal('detail',`<div class="detail-top"><div class="detail-bottle">${bottle(p)}</div><div><p class="eyebrow">${esc(p.house)}</p><h2 id="modal-title">${esc(p.name)}</h2><p>${esc(p.strength)} · ${esc(p.size)} ml</p><p class="price">${money(p.price)}</p></div></div><h3>The notes</h3><div class="note-tags">${p.notes.map(n=>`<span>${esc(n)}</span>`).join('')||'<p>No notes recorded.</p>'}</div><h3>Recorded ingredients</h3><p>${esc(p.ingredients.join(' · ')||'No ingredient data recorded.')}</p><h3>In store</h3><button class="outline-button" data-action="stock-detail" data-id="${p.id}">FIND IN STORES →</button><ul class="stock-list">${p.inventory.map(s=>`<li><span>${esc(stores.get(s.store_id)?.city||'Store '+s.store_id)} · ${esc(stores.get(s.store_id)?.street||'')}</span><strong>${s.bottles>0?esc(s.bottles)+' bottles':'Out of stock'}</strong></li>`).join('')||'<li>No store availability recorded.</li>'}</ul><div class="detail-actions"><button class="pill" data-action="add-bag" data-id="${p.id}">ADD TO BAG →</button><button class="outline-button" data-action="sample" data-id="${p.id}">SCRATCH & SNIFF</button></div><p class="form-note">Your bag saves a selection in this browser tab. Online checkout is not available yet.</p>`,true);
  }
  function updateBag(){state.bag=state.bag.filter(id=>state.products.some(p=>p.id===id));$('#bag-count').textContent=state.bag.length;try{sessionStorage.setItem('sillage-bag',JSON.stringify(state.bag));}catch(_){} }
  function bag(){
    const products=state.bag.map(id=>state.products.find(p=>p.id===id)).filter(Boolean);
    openModal('bag',`<p class="eyebrow">YOUR SELECTION</p><h2 id="modal-title">The bag.</h2>${products.map(p=>`<div class="bag-row"><div><strong>${esc(p.name)}</strong><p>${esc(p.house)} · ${p.size} ml · ${money(p.price)}</p></div><button data-action="remove-bag" data-id="${p.id}" aria-label="Remove ${esc(p.name)}">REMOVE ×</button></div>`).join('')||'<p>Your bag is waiting for its first fragrance.</p>'}${products.length?`<p class="price">${money(products.reduce((s,p)=>s+Number(p.price),0))}</p><p>Online checkout is not available yet. The team desk can record a single-bottle purchase for an existing customer.</p>`:''}<button class="pill" data-action="close-modal">KEEP EXPLORING →</button>`);
  }
  function sample(id){const p=state.products.find(p=>p.id===id);openModal('sample',`<p class="eyebrow">SCRATCH & SNIFF</p><h2 id="modal-title">Three complimentary samples.</h2><p>Starting with <strong>${esc(p?.name||'your next fragrance')}</strong>.</p><p>The sample programme is not available yet. No request or shipment will be created.</p><button class="pill" data-action="detail" data-id="${p?.id||0}">EXPLORE THIS FRAGRANCE →</button>`);}
  function account(){openModal('account',`<p class="eyebrow">WELCOME TO SILLAGE</p><h2 id="modal-title">A place for your collection.</h2><p>Customer sign-in and purchase history are not available yet. You can register your customer details below.</p><button class="pill" data-action="register">REGISTER AS A CUSTOMER →</button><p class="form-note">Registration creates a customer record. It does not create a login password yet.</p>`);}
  function register(){
    openModal('register',`<p class="eyebrow">JOIN THE COLLECTION</p><h2 id="modal-title">Make yourself known.</h2><form id="register-form"><div class="form-row"><label class="field">FIRST NAME<input name="first_name" autocomplete="given-name" maxlength="45" required></label><label class="field">LAST NAME<input name="last_name" autocomplete="family-name" maxlength="45" required></label></div><label class="field">EMAIL<input name="email" type="email" autocomplete="email" maxlength="100" required></label><label class="field">COUNTRY<select name="country_id" required><option value="">Choose your country</option>${state.countries.map(c=>`<option value="${c.id}">${esc(c.name)}</option>`).join('')}</select></label><button type="submit" class="pill">REGISTER CUSTOMER →</button></form>${resultBox}<p class="form-note">${state.preview?'Preview only. Registration requires the app connected to MySQL.':'This saves a customer record, without a login password.'}</p>`);
    $('#register-form').addEventListener('submit',async e=>{e.preventDefault();const b=$('button[type=submit]',e.target);b.disabled=true;try{const r=await api('/api/register',Object.fromEntries(new FormData(e.target)));result(r.message);e.target.reset();}catch(err){result(err.message,true);}finally{b.disabled=false;}});
  }
  function table(rows,columns){return `<div class="table-wrap"><table><thead><tr>${columns.map(c=>`<th scope="col">${esc(c[1])}</th>`).join('')}</tr></thead><tbody>${rows.map(r=>`<tr>${columns.map(c=>`<td>${esc(c[2]?c[2](r[c[0]]):r[c[0]])}</td>`).join('')}</tr>`).join('')}</tbody></table></div>`;}
  function noteSearch(){
    openModal('note-search',`<p class="eyebrow">SEARCH THE COLLECTION</p><h2 id="modal-title">A note to follow.</h2><p>Find fragrances with an exact note name.</p><form id="note-form"><label class="field">FRAGRANCE NOTE<input name="note" list="notes" maxlength="45" placeholder="Vetiver" required><datalist id="notes">${groups('note').map(n=>`<option value="${esc(n)}"></option>`).join('')}</datalist></label><button class="pill" type="submit">FIND FRAGRANCES →</button></form>${resultBox}<div id="search-results"></div>`);
    $('#note-form').addEventListener('submit',async e=>{e.preventDefault();const b=$('button',e.target);b.disabled=true;try{const note=new FormData(e.target).get('note');const r=await api('/api/search?note='+encodeURIComponent(note));result(`${r.rows.length} matching fragrance names.`);$('#search-results').innerHTML=r.rows.length?table(r.rows,[['Fragrance_Name','Fragrance']]):'<p>No fragrances found with that exact note.</p>';}catch(err){result(err.message,true);}finally{b.disabled=false;}});
  }
  async function natural(){openModal('natural',`<p class="eyebrow">THE INGREDIENT REPORT</p><h2 id="modal-title">Look a little closer.</h2><p>Classification from the recorded ingredient data.</p><div id="natural-results" role="status">Loading…</div><p class="form-note">“Clean” is the label in the project query, not a health or safety certification. Records can be incomplete.</p>`,true);try{const r=await api('/api/natural');if(modal.dataset.view!=='natural')return;$('#natural-results').innerHTML=table(r.rows,[['Fragrance_Name','Fragrance'],['Name','House'],['Natural_Status','Classification']]);}catch(err){if($('#natural-results'))$('#natural-results').textContent=err.message;}}
  function panelMessage(panel, message, error=false) {
    const node=$('.panel-result',panel);node.hidden=false;
    node.className='panel-result result'+(error?' error':'');node.textContent=message;
  }
  function setTab(name, fragranceName='') {
    if(!['collection','stock','top-sellers','add-fragrance','add-brand'].includes(name))return;
    $$('.collection-tabs [role=tab]').forEach(tab=>{const active=tab.dataset.tab===name;tab.setAttribute('aria-selected',String(active));tab.tabIndex=active?0:-1;});
    $$('#catalog [role=tabpanel]').forEach(panel=>panel.hidden=panel.id!==name+'-panel');
    if(name==='stock')stockPanel(fragranceName);
    if(name==='top-sellers')topSellersPanel();
    if(name==='add-fragrance')addFragrancePanel();
    if(name==='add-brand')addBrandPanel();
  }
  $('.collection-tabs').addEventListener('keydown',e=>{
    if(!['ArrowLeft','ArrowRight','Home','End'].includes(e.key))return;
    const tabs=$$('.collection-tabs [role=tab]'),i=tabs.indexOf(document.activeElement);if(i<0)return;
    const next=e.key==='Home'?0:e.key==='End'?tabs.length-1:(i+(e.key==='ArrowLeft'?-1:1)+tabs.length)%tabs.length;
    e.preventDefault();tabs[next].focus();setTab(tabs[next].dataset.tab);
  });
  function stockPanel(fragranceName='') {
    const panel=$('#stock-panel');
    panel.innerHTML=`<div class="feature-heading"><p class="eyebrow">CLOSER THAN YOU THINK</p><h3>Find your fragrance in store.</h3><p>Search an exact fragrance name to see locations with bottles in stock.</p></div><form id="stock-form" class="feature-form"><label class="field">FRAGRANCE NAME<input name="fragrance_name" list="stock-fragrances" maxlength="100" value="${esc(fragranceName)}" required placeholder="Choose or type a fragrance name"><datalist id="stock-fragrances">${[...new Set(state.products.map(p=>p.name))].sort().map(n=>`<option value="${esc(n)}"></option>`).join('')}</datalist></label><button class="pill" type="submit">FIND IN STORES →</button></form><div class="panel-result result" role="status" hidden></div><div class="stock-results"></div><p class="feature-note">Results cover every record with this name, including different sizes or houses. Separate inventory rows may show the same store more than once.</p>`;
    $('#stock-form').addEventListener('submit',async e=>{
      e.preventDefault();const button=$('button[type=submit]',e.target);button.disabled=true;$('.stock-results',panel).innerHTML='';
      try{const name=new FormData(e.target).get('fragrance_name');const r=await api('/api/stock?fragrance_name='+encodeURIComponent(name));
        panelMessage(panel,r.rows.length?`${r.rows.length} in-stock inventory rows, highest stock first.`:'No in-stock locations found for that exact fragrance name.');
        $('.stock-results',panel).innerHTML=r.rows.length?table(r.rows,[['City','City'],['Building','Building',v=>v||'—'],['Street','Street'],['Num_Bottles','Bottles']]):'';
      }catch(err){panelMessage(panel,err.message,true);}finally{button.disabled=false;}
    });
    if(fragranceName)$('#stock-form').requestSubmit();
  }
  function topSellersPanel() {
    const panel=$('#top-sellers-panel');
    panel.innerHTML='<div class="feature-heading"><p class="eyebrow">THE MOST CHOSEN</p><h3>Five favourites.</h3><p>The five fragrance variants with the most recorded purchases.</p></div><button class="outline-button" id="refresh-top-sellers">REFRESH REPORT ↻</button><div class="panel-result result" role="status" hidden></div><div class="seller-results"></div><p class="feature-note">Variants are counted separately. Different variants with the same name may appear in separate rows. This report counts purchases, not revenue.</p>';
    const refresh=async()=>{const button=$('#refresh-top-sellers');button.disabled=true;$('.seller-results',panel).innerHTML='';
      try{const r=await api('/api/top-sellers');panelMessage(panel,r.rows.length?`${r.rows.length} top-selling variants.`:'There are no recorded purchases yet.');$('.seller-results',panel).innerHTML=r.rows.length?table(r.rows,[['Fragrance_Name','Fragrance'],['Total_Purchases','Purchases']]):'';
      }catch(err){panelMessage(panel,err.message,true);}finally{button.disabled=false;}
    };
    $('#refresh-top-sellers').addEventListener('click',refresh);refresh();
  }
  function updateRoleNote() {
    const note=$('#fragrance-session-note');
    if(note)note.textContent=state.staff?'You are signed in to the team desk.':'Browsing with customer access. Team members can sign in through the team desk.';
    const brandNote=$('#brand-session-note'),brandButton=$('#add-brand-form button[type=submit]'),brandLogin=$('#brand-login');
    if(brandNote)brandNote.textContent=state.preview?'Preview only. No brand will be saved here.':state.staff?'You are signed in to the team desk.':'Sign in to the team desk to add a brand.';
    if(brandButton)brandButton.disabled=!state.staff||state.preview;
    if(brandLogin)brandLogin.hidden=state.staff||state.preview;
  }
  async function refreshCatalogue() {
    const catalog=await api('/api/catalog');Object.assign(state,catalog);
    const houses=$('#add-fragrance-form select[name=brand_id]');
    if(houses){const selected=houses.value;houses.innerHTML='<option value="">Choose a house</option>'+state.brands.map(b=>`<option value="${b.id}">${esc(b.name)}</option>`).join('');houses.value=selected;}
    renderCarousel();renderCatalog();
  }
  function addBrandPanel() {
    const panel=$('#add-brand-panel');
    panel.innerHTML=`<div class="feature-heading"><p class="eyebrow">A NEW HOUSE</p><h3>Add a brand.</h3><p>Create a house before adding its first fragrance.</p></div><p class="feature-note" id="brand-session-note"></p><button class="outline-button" id="brand-login" data-action="staff">TEAM SIGN IN →</button><form id="add-brand-form" class="feature-form"><div class="form-row"><label class="field">BRAND NAME<input name="name" maxlength="60" required></label><label class="field">COUNTRY<select name="country_id" required><option value="">Choose a country</option>${state.countries.map(c=>`<option value="${c.id}">${esc(c.name)}</option>`).join('')}</select></label></div><p class="feature-note">Choose an existing country. New country registration is not available here.</p><button class="pill" type="submit">ADD BRAND →</button></form><div class="panel-result result" role="status" hidden></div><button class="text-button" data-action="open-add-fragrance">CONTINUE TO ADD FRAGRANCE →</button>`;
    updateRoleNote();
    $('#add-brand-form').addEventListener('submit',async e=>{
      e.preventDefault();const button=$('button[type=submit]',e.target);button.disabled=true;let saved=false;
      try{const r=await api('/api/brands',Object.fromEntries(new FormData(e.target)));saved=true;panelMessage(panel,`${r.message} Brand ID: ${r.brand_id}.`);e.target.reset();await refreshCatalogue();
      }catch(err){panelMessage(panel,saved?'Brand saved, but the house list could not refresh. Reload before submitting again.':err.message,!saved);}finally{button.disabled=!state.staff||state.preview;}
    });
  }
  function addFragrancePanel() {
    const panel=$('#add-fragrance-panel');
    panel.innerHTML=`<div class="feature-heading"><p class="eyebrow">GROW THE COLLECTION</p><h3>Add a fragrance.</h3><p>Enter an existing house and the details of one fragrance variant.</p></div><p class="feature-note" id="fragrance-session-note">${state.staff?'You are signed in to the team desk.':'Browsing with customer access. Team members can sign in through the team desk.'}</p><form id="add-fragrance-form" class="feature-form"><div class="form-row"><label class="field">FRAGRANCE NAME<input name="fragrance_name" maxlength="100" required></label><label class="field">HOUSE<select name="brand_id" required><option value="">Choose a house</option>${state.brands.map(b=>`<option value="${b.id}">${esc(b.name)}</option>`).join('')}</select></label></div><div class="form-row"><label class="field">STRENGTH<input name="strength" maxlength="45" placeholder="Eau de Parfum" required></label><label class="field">BOTTLE SIZE (ML)<input name="size" type="number" min="1" max="2147483647" step="1" required></label></div><label class="field">PRICE (USD)<input name="price" type="number" min="0" max="99999999.99" step="0.01" required></label><p class="feature-note">Adding a fragrance does not add bottles to a store. Store stock is managed separately.</p><button class="pill" type="submit">ADD FRAGRANCE →</button></form><div class="panel-result result" role="status" hidden></div>${state.preview?'<p class="feature-note">Preview only. No fragrance will be saved here.</p>':''}`;
    $('#add-fragrance-form').addEventListener('submit',async e=>{
      e.preventDefault();const button=$('button[type=submit]',e.target);button.disabled=true;let saved=false;
      try{const r=await api('/api/fragrances',Object.fromEntries(new FormData(e.target)));saved=true;panelMessage(panel,`${r.message} Catalogue ID: ${r.fragrance_id}.`);e.target.reset();
        const catalog=await api('/api/catalog');state.products=catalog.products;state.brands=catalog.brands;renderCarousel();renderCatalog();
      }catch(err){panelMessage(panel,saved?'Fragrance saved, but the catalogue display could not refresh. Reload before submitting again.':err.message,!saved);}finally{button.disabled=false;}
    });
  }
  function staff(){
    if(state.staff){desk();return;}
    openModal('staff-login',`<p class="eyebrow">TEAM DESK</p><h2 id="modal-title">Behind the collection.</h2><p>Sign in to view reports, record purchases, restock stores, and manage the collection.</p><form id="staff-login-form"><label class="field">TEAM-DESK PASSWORD<input name="password" type="password" autocomplete="current-password" required maxlength="1024"></label><button class="pill" type="submit">SIGN IN →</button></form>${resultBox}${!state.staff_enabled?'<p class="form-note">The team desk is disabled in this preview. Start the local Python app with --staff to enable it.</p>':''}`);
    $('#staff-login-form').addEventListener('submit',async e=>{e.preventDefault();const b=$('button',e.target);b.disabled=true;try{const r=await api('/api/staff/login',Object.fromEntries(new FormData(e.target)));state.csrf=r.csrf;state.staff=true;updateRoleNote();desk();}catch(err){result(err.message,true);}finally{b.disabled=false;}});
  }
  function desk(tab='revenue'){
    openModal('desk',`<p class="eyebrow">TEAM DESK</p><h2 id="modal-title">Behind the collection.</h2><div class="desk-tabs"><button data-action="desk-revenue" class="${tab==='revenue'?'active':''}">REVENUE</button><button data-action="desk-discounts" class="${tab==='discounts'?'active':''}">PURCHASE FOLLOW-UP</button><button data-action="desk-purchase" class="${tab==='purchase'?'active':''}">RECORD PURCHASE</button><button data-action="desk-restock" class="${tab==='restock'?'active':''}">RESTOCK</button><button data-action="open-add-fragrance">ADD FRAGRANCE</button><button data-action="open-add-brand">ADD BRAND</button></div><div id="desk-body"></div><div class="desk-foot"><button class="text-button" data-action="staff-logout">SIGN OUT ↗</button></div>`,true);
    const body=$('#desk-body');
    if(tab==='revenue'){
      const cities=[...new Set(state.stores.map(s=>s.city))].sort();
      body.innerHTML=`<form id="revenue-form"><label class="field">STORE CITY<select name="city"><option value="">All stores</option>${cities.map(c=>`<option>${esc(c)}</option>`).join('')}</select></label><button class="pill" type="submit">VIEW REVENUE →</button></form>${resultBox}<div id="revenue-value" class="metric"></div><p class="form-note">The existing report totals current fragrance prices for recorded purchases. It does not store historical sale prices.</p>`;
      $('#revenue-form').addEventListener('submit',async e=>{e.preventDefault();const b=$('button',e.target);b.disabled=true;$('#revenue-value').textContent='';try{const city=new FormData(e.target).get('city');const r=await api('/api/revenue'+(city?'?city='+encodeURIComponent(city):''));$('#revenue-value').textContent=money(r.TotalRevenue);result(r.TotalRevenue==null?'No matching purchases.':'Report loaded.');}catch(err){result(err.message,true);}finally{b.disabled=false;}});
    } else if(tab==='discounts'){
      const before=new Date();before.setDate(before.getDate()-30);
      body.innerHTML=`<p>Find purchase rows older than a chosen date for fragrances priced above $200. This report does not check each customer’s most recent purchase.</p><form id="discount-form"><label class="field">PURCHASED BEFORE<input name="before" type="date" value="${before.toISOString().slice(0,10)}" required></label><button class="pill" type="submit">VIEW MATCHING PURCHASES →</button></form>${resultBox}<div id="discount-results"></div>`;
      $('#discount-form').addEventListener('submit',async e=>{e.preventDefault();const b=$('button',e.target);b.disabled=true;try{const r=await api('/api/discounts?before='+encodeURIComponent(new FormData(e.target).get('before')));result(`${r.rows.length} matching purchase rows.`);$('#discount-results').innerHTML=table(r.rows,[['Name','Customer'],['Price','Current price',money],['Purchase_Date','Purchase date']]);}catch(err){result(err.message,true);}finally{b.disabled=false;}});
    } else if(tab==='restock') {
      body.innerHTML=`<p>Add bottles to an existing store inventory record. A fragrance with zero bottles can be restocked; a missing store/fragrance record cannot be created here.</p><form id="restock-form"><label class="field">STORE<select name="store_id" required><option value="">Choose a store</option>${state.stores.map(s=>`<option value="${s.id}">${esc(s.city)} · ${esc(s.street)} · #${s.id}</option>`).join('')}</select></label><label class="field">FRAGRANCE<select name="fragrance_id" required><option value="">Choose a fragrance</option>${state.products.map(p=>`<option value="${p.id}">${esc(p.house)} · ${esc(p.name)} · ${esc(p.strength)} · ${p.size} ml · #${p.id}</option>`).join('')}</select></label><label class="field">BOTTLES TO ADD<input name="bottles" type="number" min="1" max="2147483647" step="1" required></label><p class="form-note" id="restock-inventory"></p><button class="pill" type="submit">RESTOCK →</button></form>${resultBox}`;
      const form=$('#restock-form');
      const showStock=()=>{const values=Object.fromEntries(new FormData(form));const product=state.products.find(p=>p.id===Number(values.fragrance_id)),stock=product?.inventory.find(s=>s.store_id===Number(values.store_id));$('#restock-inventory').textContent=!values.store_id||!values.fragrance_id?'Choose a store and a fragrance to view the recorded stock.':stock?`${stock.bottles} bottles currently recorded in this store.`:'No inventory record exists for this store and fragrance. Restock will not create one.';};
      form.addEventListener('change',showStock);showStock();
      form.addEventListener('submit',async e=>{
        e.preventDefault();const button=$('button[type=submit]',form);button.disabled=true;let saved=false;
        try{const r=await api('/api/restock',Object.fromEntries(new FormData(form)));saved=true;result(r.message);form.elements.bottles.value='';await refreshCatalogue();if(form.isConnected)showStock();
        }catch(err){if(form.isConnected)result(saved?'Restock saved, but the stock display could not refresh. Reload before submitting again.':err.message,!saved);}finally{button.disabled=false;}
      });
    } else {
      body.innerHTML=`<p>Record one bottle sold to an existing customer. A successful purchase reduces inventory and adds the purchase record together.</p><form id="purchase-form"><label class="field">CUSTOMER ID<input name="customer_id" type="number" min="1" max="2147483647" step="1" required></label><label class="field">FRAGRANCE<select name="fragrance_id" required>${state.products.map(p=>`<option value="${p.id}">${esc(p.name)} · ${p.size} ml · #${p.id}</option>`).join('')}</select></label><label class="field">STORE<select name="store_id" required>${state.stores.map(s=>`<option value="${s.id}">${esc(s.city)} · ${esc(s.street)} · #${s.id}</option>`).join('')}</select></label><p class="form-note" id="inventory-before"></p><button class="pill" type="submit">RECORD ONE-BOTTLE PURCHASE →</button></form>${resultBox}`;
      const showInventory=()=>{const data=Object.fromEntries(new FormData($('#purchase-form')));const p=state.products.find(p=>p.id===Number(data.fragrance_id)), stock=p?.inventory.find(s=>s.store_id===Number(data.store_id));$('#inventory-before').textContent=stock?`${stock.bottles} bottles recorded in this store.`:'No inventory row is recorded for this fragrance and store.';};
      $('#purchase-form').addEventListener('change',showInventory);showInventory();
      $('#purchase-form').addEventListener('submit',async e=>{e.preventDefault();const b=$('button',e.target);b.disabled=true;let saved=false;try{const r=await api('/api/purchase',Object.fromEntries(new FormData(e.target)));saved=true;result(r.message);const catalog=await api('/api/catalog');state.products=catalog.products;showInventory();renderCatalog();}catch(err){result(saved?'Purchase saved, but the inventory display could not refresh. Reload before recording another purchase.':err.message,!saved);}finally{b.disabled=false;}});
    }
  }
  document.addEventListener('click',async e=>{
    const b=e.target.closest('button[data-action],button[data-mode],button[data-tab]');if(!b)return;
    if(b.dataset.tab){setTab(b.dataset.tab);return;}
    if(b.dataset.mode&&!b.dataset.action){setMode(b.dataset.mode);return;}
    const action=b.dataset.action,id=Number(b.dataset.id);
    if(action==='close-modal')modal.close();
    else if(action==='prev')step(-1);else if(action==='next')step(1);else if(action==='motion')motion();
    else if(action==='choose-group')browse();else if(action==='browse-note')browse('note');else if(action==='browse-house')browse('house');
    else if(action==='choose'){setMode(b.dataset.mode,b.dataset.group);modal.close();}
    else if(action==='select-card'){const i=Number(b.dataset.index);if(i===state.active)details(state.slides[i].id);else{state.velocity=0;state.speed=0;state.target=state.pos+relative(i,state.pos);if(reduced.matches){state.pos=state.target;state.target=null;paintCarousel();}}}
    else if(action==='active-detail'){if(state.slides[state.active])details(state.slides[state.active].id);}
    else if(action==='detail')details(id);else if(action==='sample')sample(id);
    else if(action==='stock-detail'){const p=state.products.find(p=>p.id===id);if(p){modal.close();setTab('stock',p.name);$('#catalog').scrollIntoView();}}
    else if(action==='open-add-fragrance'){modal.close();setTab('add-fragrance');$('#catalog').scrollIntoView();}
    else if(action==='open-add-brand'){modal.close();setTab('add-brand');$('#catalog').scrollIntoView();}
    else if(action==='shop'||action==='show-all')showCatalog();else if(action==='explore')showCatalog({mode:state.mode,group:state.group});
    else if(action==='load-more'){state.limit+=24;renderCatalog();}
    else if(action==='add-bag'){if(!state.bag.includes(id)){state.bag.push(id);updateBag();toast('Added to your bag.');}else toast('This bottle is already in your bag.');}
    else if(action==='bag')bag();else if(action==='remove-bag'){state.bag=state.bag.filter(x=>x!==id);updateBag();bag();}
    else if(action==='account')account();else if(action==='register')register();
    else if(action==='note-search')noteSearch();else if(action==='natural')natural();
    else if(action==='staff')staff();else if(action.startsWith('desk-'))desk(action.slice(5));
    else if(action==='staff-logout'){try{const r=await api('/api/staff/logout',{});state.csrf=r.csrf;state.staff=false;updateRoleNote();modal.close();toast('Signed out.');}catch(err){toast(err.message);}}
  });
  modal.addEventListener('click',e=>{if(e.target===modal){const r=modal.getBoundingClientRect();if(e.clientX<r.left||e.clientX>r.right||e.clientY<r.top||e.clientY>r.bottom)modal.close();}});
  async function init(){
    try{
      const [catalog,status]=await Promise.all([api('/api/catalog'),api('/api/status')]);
      Object.assign(state,catalog,status);updateBag();setMode('note');renderCatalog();
      $('#data-mode').textContent=state.preview?'CATALOGUE PREVIEW':'CONNECTED TO MYSQL';
      if(state.paused){document.body.classList.add('motion-paused');$('#motion-toggle').textContent='RESUME MOTION';}
    }catch(err){$('#carousel-message').textContent=err.message;$('#data-mode').textContent='CONNECTION UNAVAILABLE';$('#product-grid').innerHTML='<p class="empty-state">The collection could not be loaded. Check the Python server connection, then reload this page.</p>';}
    requestAnimationFrame(frame);
  }
  init();
})();
