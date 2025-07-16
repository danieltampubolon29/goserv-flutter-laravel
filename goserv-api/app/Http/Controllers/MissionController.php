<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Mission;

class MissionController extends Controller
{
    public function index()
    {
        return response()->json([
            'success' => true,
            'data' => Mission::all()
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nama' => 'required|string',
            'harga' => 'required|integer',
            'point' => 'required|integer',
            'tanggal_mulai' => 'required|date',
            'tanggal_selesai' => 'required|date',
            'status' => 'required|in:pending,aktif,selesai',
        ]);

        $mission = Mission::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Mission berhasil ditambahkan',
            'data' => $mission
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $mission = Mission::findOrFail($id);

        $data = $request->validate([
            'nama' => 'required|string',
            'harga' => 'required|integer',
            'point' => 'required|integer',
            'tanggal_mulai' => 'required|date',
            'tanggal_selesai' => 'required|date',
            'status' => 'required|in:pending,aktif,selesai',
        ]);

        $mission->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Mission berhasil diperbarui',
            'data' => $mission
        ]);
    }

    public function destroy($id)
    {
        $mission = Mission::findOrFail($id);
        $mission->delete();

        return response()->json([
            'success' => true,
            'message' => 'Mission berhasil dihapus'
        ]);
    }
}
