function bool(v) {
  return v === 1 || v === true;
}

function stall(row) {
  return {
    id: row.id,
    name: row.name,
    cuisine: row.cuisine,
    owner: row.owner,
    status: row.status,
    spot: row.spot,
    fee: row.fee,
  };
}

function event(row, tags = [], stalls = []) {
  return {
    id: row.id,
    name: row.name,
    type: row.type,
    status: row.status,
    color: row.color,
    glyph: row.glyph,
    dateLabel: row.date_label,
    time: row.time,
    location: row.location,
    city: row.city,
    capacity: row.capacity,
    fee: row.fee,
    attendees: row.attendees,
    desc: row.descr || '',
    tags,
    stalls,
    organizer: row.organizer,
    taken: row.taken,
    joinState: row.join_state,
  };
}

function profile(row) {
  if (!row) return null;
  return {
    name: row.name,
    owner: row.owner,
    role: row.role,
    roleLabel: row.role_label,
    events: row.events,
    vendors: row.vendors,
    cuisine: row.cuisine,
    rating: row.rating == null ? null : Number(row.rating),
    reviews: row.reviews,
    bio: row.bio || '',
    color: row.color,
    glyph: row.glyph,
    email: row.email,
    phone: row.phone,
  };
}

function settings(row) {
  if (!row) return {};
  return {
    pushApps: bool(row.push_apps),
    pushUpdates: bool(row.push_updates),
    email: bool(row.email),
    visible: bool(row.visible),
    location: bool(row.location),
  };
}

function participation(row) {
  return { id: row.event_id, status: row.status, spot: row.spot };
}

function notif(row) {
  return {
    id: row.id,
    kind: row.kind,
    read: bool(row.is_read),
    time: row.time,
    actor: row.actor,
    cuisine: row.cuisine,
    eventId: row.event_id,
    eventName: row.event_name,
    text: row.text,
    actionable: bool(row.actionable),
    stallId: row.stall_id,
    resolved: row.resolved,
  };
}

module.exports = { stall, event, profile, settings, participation, notif };
