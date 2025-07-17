<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Mission;
use App\Models\Point;
use Illuminate\Support\Carbon;

class MissionController extends Controller
{

    public function claimMission(Request $request)
    {
        try {
            $request->validate([
                'user_id' => 'required|exists:users,id',
                'mission_id' => 'required|exists:missions,id',
                'point' => 'required|integer',
            ]);

            $existing = Point::where('user_id', $request->user_id)
                ->where('mission_id', $request->mission_id)
                ->first();

            if ($existing) {
                return response()->json([
                    'success' => false,
                    'message' => 'Mission already claimed'
                ], 400);
            }

            $mission = Mission::findOrFail($request->mission_id);
            $totalHarga = \App\Models\Service::where('user_id', $request->user_id)
                ->whereBetween('tanggal', [$mission->tanggal_mulai, $mission->tanggal_selesai])
                ->sum('harga');

            if ($totalHarga < $mission->harga) {
                return response()->json([
                    'success' => false,
                    'message' => 'Mission not completed yet'
                ], 400);
            }

            // Create point record
            $point = Point::create([
                'user_id' => $request->user_id,
                'mission_id' => $request->mission_id,
                'point' => $request->point,
                'transaksi' => 'setor', 
                'tanggal' => Carbon::now()->toDateString(),
            ]);


            return response()->json([
                'success' => true,
                'message' => 'Mission claimed successfully',
                'data' => $point
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error claiming mission: ' . $e->getMessage()
            ], 500);
        }
    }

    public function userMissionProgress($user_id)
    {
        try {
            $missions = \App\Models\Mission::where('status', 'aktif')->get();

            $results = [];

            foreach ($missions as $mission) {
                $totalHarga = \App\Models\Service::where('user_id', $user_id)
                    ->whereBetween('tanggal', [$mission->tanggal_mulai, $mission->tanggal_selesai])
                    ->sum('harga');

                // Check if mission is claimed
                $claimed = Point::where('user_id', $user_id)
                    ->where('mission_id', $mission->id)
                    ->exists();

                $results[] = [
                    'id' => $mission->id,
                    'nama' => $mission->nama,
                    'harga' => $mission->harga,
                    'point' => $mission->point,
                    'tanggal_mulai' => $mission->tanggal_mulai,
                    'tanggal_selesai' => $mission->tanggal_selesai,
                    'status' => $mission->status,
                    'progress' => $totalHarga,
                    'claimed' => $claimed, // Add claimed status
                ];
            }

            return response()->json([
                'success' => true,
                'data' => $results
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error fetching missions: ' . $e->getMessage()
            ], 500);
        }
    }

    public function active()
    {
        $missions = Mission::where('status', 'aktif')->get();

        return response()->json([
            'success' => true,
            'data' => $missions
        ]);
    }

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
